#!/bin/bash
set -xeuo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

# This script uses ideas from the build script for BLAST. See comments there.

# $SHARE_DIR contains the actual igblastn and igblastp binaries and also the
# required data files. Wrappers will be installed into $PREFIX/bin that set
# $IGDATA to point to those data files.

SHARE_DIR="${PREFIX}/share/igblast"
mkdir -p ${SHARE_DIR}/bin

mkdir -p ${PREFIX}/bin

# Work directory
RESULT_PATH="${SRC_DIR}/c++/Release"
export AR="${AR} rcs"

uname_str=$(uname -s)
arch_str=$(uname -m)

if [[ "$uname_str" == "Linux" ]]; then
	export CONFIG_ARGS="--with-runpath=\"${LIB_INSTALL_DIR}\" --with-openmp --with-hard-runpath --with-dll"
	if [[ "$(uname -m)" == "x86_64" ]]; then
            export CONFIG_ARGS="${CONFIG_ARGS} --with-64"
	fi
else
	export CONFIG_ARGS='--without-openmp --without-dll --without-gcrypt --without-zstd'
fi

if [[ "$uname_str" == "Linux" || ("$uname_str" == "Darwin" && "$arch_str" == "arm64") ]]; then
    cd c++

    ./configure --with-z="${PREFIX}" \
         --with-bz2="${PREFIX}" --with-vdb="${PREFIX}" \
         CC="${CC}" CFLAGS="${CFLAGS}" CXX="${CXX}" \
         CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
         CPPFLAGS="${CPPFLAGS}" --with-strip --without-debug \
         --with-bin-release --with-mt --without-autodep --without-makefile-auto-update \
         --with-flat-makefile --without-caution --without-pcre --without-lzo \
         --with-sqlite3="${PREFIX}" --without-krb5 --without-gnutls --without-boost --with-static \
	 ${CONFIG_ARGS}

    make -j"${CPU_COUNT}"

    # Move one up so it looks like the binary release
    mv ReleaseMT/bin .
    mv src/app/igblast/{internal_data,optional_file} ${SHARE_DIR}
elif [[ "$uname_str" == "Darwin" && "$arch_str" == "x86_64" ]]; then
    # On Intel macOS, use prebuilt binaries
    mv internal_data optional_file ${SHARE_DIR}
else
    echo "Unsupported OS or architecture: ${uname_str} ${arch_str}"
    exit 1
fi

install -v -m 0755 bin/makeblastdb ${PREFIX}/bin
install -v -m 0755 bin/{igblastn,igblastp} ${SHARE_DIR}/bin

# Replace the shebang
sed '1 s|^.*$|#!/usr/bin/env perl|g' bin/edit_imgt_file.pl > ${PREFIX}/bin/edit_imgt_file.pl
chmod +x ${PREFIX}/bin/edit_imgt_file.pl

# Install wrappers
for name in igblastn igblastp; do
    cat >"${PREFIX}/bin/${name}" <<EOF
#!/bin/sh
IGDATA="\${IGDATA-"${PREFIX}/share/igblast"}" exec "${PREFIX}/share/igblast/bin/${name}" "\${@}"
EOF
    chmod +x ${PREFIX}/bin/${name}
done

# To Do
# - makeblastdb conflicts with the one from BLAST
