#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
export LC_ALL=C

install -d "${PREFIX}/bin"

chmod +x htslib-1.6/version.sh
sed -i.bak 's|-O2|-O3 -I$(PREFIX)/include -Wno-implicit-function-declaration|g' htslib-1.6/Makefile
sed -i.bak 's|AR     = ar|#AR     = ar|' htslib-1.6/Makefile
sed -i.bak 's|-lpthread|-pthread|g' htslib-1.6/Makefile
sed -i.bak 's|-g -O2|-g -O3 -Wno-implicit-function-declaration -I$(PREFIX)/include|' htslib-1.6/config.mk
rm -f htslib-1.6/*.bak

if [[ `uname -m` == "aarch64" || `uname -m` == "arm64" ]]; then
	sed -i'.bak' 's/\-mpopcnt//g' Makefile
fi

sed -i.bak 's|-lpthread|-pthread|g' Makefile
sed -i.bak 's|-std=c++11 -O2|-std=c++14 -O3 -march=x86-64-v3 -Wno-implicit-function-declaration|' Makefile
sed -i.bak 's|-O2|-O3|g' Makefile

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac
rm -f *.bak

case $(uname -s) in
    "Darwin")
	make no_omp CC="${CC} -Wno-implicit-function-declaration ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
	;;
    "Linux")
	make CC="${CC} -Wno-implicit-function-declaration ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
	;;
esac

install -v -m 0755 akt "${PREFIX}/bin"
