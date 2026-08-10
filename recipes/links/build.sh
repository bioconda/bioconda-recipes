#!/bin/bash
set -eux -o pipefail

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

autoreconf -if
 ./configure --prefix="${PREFIX}" \
	--disable-option-checking --enable-silent-rules --disable-dependency-tracking \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS}" \
	CC="${CC}" \
	CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install

mv ${PREFIX}/bin/LINKS-make ${PREFIX}/bin/LINKS-make-real
echo "#!/bin/bash" > ${PREFIX}/bin/LINKS-make
echo "make -f $(command -v ${PREFIX}/bin/LINKS-make-real) \$@" >> ${PREFIX}/bin/LINKS-make
