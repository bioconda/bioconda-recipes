#!/bin/bash

export CPATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

autoreconf -if
./configure --prefix="${PREFIX}" --with-boost="${PREFIX}" \
	--with-zlib="${PREFIX}" --disable-option-checking --enable-silent-rules \
	--disable-dependency-tracking CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" \
	CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"

sed -i.bak 's|CXXFLAGS = -g -O3|CXXFLAGS = -g -O3 -std=c++14|' src/mcall/Makefile
sed -i.bak 's|-lpthread|-pthread|' src/mcall/Makefile
sed -i.bak 's|-O3 -pipe -std=c++11|-O3 -pipe -std=c++14|' src/mcomp/Makefile
sed -i.bak 's|-lpthread|-pthread|' src/mcomp/Makefile
sed -i.bak 's|-std=c++11|-std=c++14|' src/pefilter/Makefile
sed -i.bak 's|-lpthread|-pthread|' src/pefilter/Makefile

make -j"${CPU_COUNT}"
make install -C src

for f in bamsort.sh moabs preprocess_novoalign.sh redepth.pl routines.pm template_for_cfg template_for_qsub
do
	install -v -m 0755 "${SRC_DIR}/bin/$f" "${PREFIX}/bin"
done

cp -Rf "${SRC_DIR}/bin/plib" "${PREFIX}/bin"
cp -f "${SRC_DIR}/lib/samtools/samtools" "${PREFIX}/bin"
