#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-narrowing"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "$PREFIX/bin"

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-std=c++0x|-O3 -std=c++14 -march=armv8-a -Wno-narrowing|' ra/Makefile.rules
	;;
    arm64)
	sed -i.bak 's|-std=c++0x|-O3 -std=c++14 -march=armv8.4-a -Wno-narrowing|' ra/Makefile.rules
	;;
    x86_64)
	sed -i.bak 's|-std=c++0x|-O3 -std=c++14 -march=x86-64-v3 -Wno-narrowing|' ra/Makefile.rules
	;;
esac

case $(uname -m) in
    aarch64|arm64)
        sed -i.bak 's|-m64||' ra/Makefile.rules
        ;;
esac

case $(uname -s) in
    Darwin)
        sed -i.bak 's|-Wall -fopenmp|-Wall -Xpreprocessor -fopenmp|' ra/Makefile.rules
		sed -i.bak 's|-lstdc++ -fopenmp|-lstdc++ -L$(PREFIX)/lib -lomp|' ra/Makefile.rules
        ;;
esac

rm -f ra/*.bak

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 bin/release/* "$PREFIX/bin"
