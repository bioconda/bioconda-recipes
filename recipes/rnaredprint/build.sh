#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

2to3 -wn scripts/RNARedPrintS*.py scripts/calcprobs.py scripts/test.py

sed -i.bak 's|-O2 -g -std=c++11|-O3 -g -std=c++14 -march=x86-64-v3|' Makefile
sed -i.bak 's|-march=native|-march=x86-64-v3|' lib/2016-pace-challenge-master/Makefile
sed -i.bak 's|g++|$(CXX) -march=x86-64-v3|g' lib/flow-cutter-pace16-master/Makefile
sed -i.bak 's|g++|$(CXX)|' lib/pacechallenge-master/Makefile
sed -i.bak 's|-std=c++11 -O3 -march=native|-std=c++14 -O3 -march=x86-64-v3|' lib/pacechallenge-master/Makefile

case $(uname -m) in
	aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' lib/2016-pace-challenge-master/Makefile
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|g' lib/flow-cutter-pace16-master/Makefile
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' lib/pacechallenge-master/Makefile
	;;
	arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' lib/2016-pace-challenge-master/Makefile
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|g' lib/flow-cutter-pace16-master/Makefile
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' lib/pacechallenge-master/Makefile
	;;
esac
rm -f *.bak

javac lib/libtw/TD.java -classpath lib/libtw/libtw.jar

make subsystem -j"${CPU_COUNT}"
make -j"${CPU_COUNT}"

make install PREFIX="${PREFIX}"
