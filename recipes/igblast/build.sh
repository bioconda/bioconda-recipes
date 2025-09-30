#!/bin/bash
set -xeuo pipefail

# This script uses ideas from the build script for BLAST. See comments there.
SHARE_DIR=$PREFIX/share/igblast
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* src/build-system/

mkdir -p $PREFIX/bin

# $SHARE_DIR contains the actual igblastn and igblastp binaries and also the
# required data files. Wrappers will be installed into $PREFIX/bin that set
# $IGDATA to point to those data files.
mkdir -p $SHARE_DIR/bin

uname_str=$(uname)
arch_str=$(uname -m)

if [[ "$uname_str" == "Linux" || ("$uname_str" == "Darwin" && "$arch_str" == "arm64") ]]; then
    export AR="$AR rcs"

    cd c++

    ./configure \
         --with-z=$PREFIX \
         --with-bz2=$PREFIX \
         --with-vdb=$PREFIX

    make -j${CPU_COUNT}

    # Move one up so it looks like the binary release
    mv ReleaseMT/bin .
    mv src/app/igblast/{internal_data,optional_file} $SHARE_DIR
elif [[ "$uname_str" == "Darwin" && "$arch_str" == "x86_64" ]]; then
    # On Intel macOS, use prebuilt binaries
    mv internal_data optional_file $SHARE_DIR
else
    echo "Unsupported OS or architecture: $uname_str $arch_str"
    exit 1
fi
install -v -m 0755 bin/makeblastdb "$PREFIX/bin"
install -v -m 0755 bin/{igblastn,igblastp} "$SHARE_DIR/bin"

# Replace the shebang
sed '1 s_^.*$_#!/usr/bin/env perl_' bin/edit_imgt_file.pl > $PREFIX/bin/edit_imgt_file.pl
chmod +x $PREFIX/bin/edit_imgt_file.pl

# Install wrappers
for name in igblastn igblastp; do
  cat >"${PREFIX}/bin/${name}" <<EOF
#!/bin/sh
IGDATA="\${IGDATA-"${PREFIX}/share/igblast"}" exec "${PREFIX}/share/igblast/bin/${name}" "\${@}"
EOF
  chmod +x $PREFIX/bin/$name
done

# To Do
# - makeblastdb conflicts with the one from BLAST
