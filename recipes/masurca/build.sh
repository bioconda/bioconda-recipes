#!/bin/bash
set -xe

export PERL_EXT_CPPFLAGS="-D_REENTRANT -D_GNU_SOURCE -fwrapv -fno-strict-aliasing -pipe -fstack-protector"
export PERL_EXT_LDFLAGS="-shared -O3 -fstack-protector"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -std=gnu11"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -Wno-use-after-free -Wno-misleading-indentation -Wno-unused-result"
export LC_ALL="en_US.UTF-8"

ROOT=`pwd -P`
[ -z "${DEST}" ] && DEST="${ROOT}"

###################
# Check for gmake #
###################
mkdir -p dist-bin
PATH="${PATH}:${ROOT}/dist-bin"
ln -sf $(which make) "${ROOT}/dist-bin/gmake"
ln -sf "${ROOT}/PkgConfig.pm" "${ROOT}/dist-bin/pkg-config"

export NUM_THREADS=`grep -c '^processor' /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1`;
BINDIR="${PREFIX}/bin"
LIBDIR="${PREFIX}/lib"
export PKG_CONFIG_PATH="${LIBDIR}/pkgconfig:${PKG_CONFIG_PATH}"

cd global-1

autoreconf -if
./configure --prefix="${PREFIX}" --bindir="${BINDIR}" --libdir="${LIBDIR}" \
	--enable-silent-rules --disable-option-checking --disable-dependency-tracking \
	CC="${CC}" CXX="${CXX}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
	CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" BOOST_ROOT="${PREFIX}"
make install-special -j"${CPU_COUNT}"

echo "Creating example config file masurca_config_example.txt:"
${BINDIR}/masurca -g masurca_config_example.txt

# MaSuRCA calls Flye as <bin>/../Flye/bin/flye and flye-minimap2 (polishing,
# scaffolding, FLYE_ASSEMBLY=1). The bundled copy is Flye 2.5, whose launcher
# requires Python 2.7, and installing it into ${PREFIX}/bin shadowed the flye
# run dependency. Point MaSuRCA's Flye path at the flye package instead.
# FLYE_ASSEMBLY=1 passes --kmer-size 21, which only Flye 2.5 accepted, so the
# flye wrapper drops that option.
mkdir -p "${PREFIX}/Flye/bin"
cat > "${PREFIX}/Flye/bin/flye" <<'EOF'
#!/usr/bin/env bash
args=(); skip=0
for a in "$@"; do
	if [ "${skip}" = 1 ]; then skip=0; continue; fi
	if [ "${a}" = "--kmer-size" ]; then skip=1; continue; fi
	args+=("${a}")
done
exec "$(dirname "$0")/../../bin/flye" "${args[@]}"
EOF
printf '#!/bin/sh\nexec "$(dirname "$0")/../../bin/flye-minimap2" "$@"\n' > "${PREFIX}/Flye/bin/flye-minimap2"
chmod 0755 "${PREFIX}/Flye/bin/flye" "${PREFIX}/Flye/bin/flye-minimap2"

find "${PREFIX}/bin" -name "*.pl" -exec sed -i '1s|^#!.*perl.*|#!/usr/bin/env perl|' {} +