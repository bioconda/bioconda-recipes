#!/bin/sh
sed -i.bak \
    -e '/^compilerCommand /  s|=.*|= '"${CXX}"'|' \
    -e '/^compilerParams /   s|=.*|= '"${CXXFLAGS} -I."'|' \
    -e '/^libCommand /       s|=.*|= '"${AR}"'|' \
    -e '/^sharedlibCommand / s|=.*|= '"${CXX}"'|' \
    -e '/^ranlibCommand /    s|=.*|= '"${RANLIB}"'|' \
    makeMakefile.config
sh ./makeMakefile.sh
make

mkdir -p "${PREFIX}/ogdf/"{lib,include}
cp _release/libOGDF.a "${PREFIX}/ogdf/lib/"
cp -R ogdf "${PREFIX}/ogdf/include/"
