#!/bin/sh

#modify makefile to use correct compiler c++
sed -i.bak -e 's/\${CC}/${CXX}/g' -e 's/\${CFLAGS}/${CXXFLAGS}/g' makefile

#remove explicit CC, CXX, and LDFLAGS definitions to use conda ones
sed -i.bak '1,4d' makefile

if [ `uname` == Darwin ]; then
	CXXFLAGS="${CXXFLAGS} -g -O3 -fopenmp -I${PREFIX}/include"
else
	CXXFLAGS="${CXXFLAGS} -fopenmp -g -O3"
fi

#now build
make

#link
mkdir -p $PREFIX/bin
mv CodingQuarry $PREFIX/bin
sed -i.bak 's|/usr/bin/python|/usr/bin/env python|' CufflinksGTF_to_CodingQuarryGFF3.py
mv CufflinksGTF_to_CodingQuarryGFF3.py $PREFIX/bin
mv run_CQ-PM_mine.sh $PREFIX/bin
mv run_CQ-PM_stranded.sh $PREFIX/bin
mv run_CQ-PM_unstranded.sh $PREFIX/bin

#fix scripts in QuarryFiles directory
if [ "$PY3K" == 1 ]; then
    2to3 -w $SRC_DIR/QuarryFiles/scripts/fastaTranslate.py
fi
sed -i.bak 's|/usr/bin/python|/usr/bin/env python|' $SRC_DIR/QuarryFiles/scripts/fastaTranslate.py
sed -i.bak 's|/usr/bin/python|/usr/bin/env python|' $SRC_DIR/QuarryFiles/scripts/gene_errors_Xs.py
sed -i.bak 's|/usr/bin/python|/usr/bin/env python|' $SRC_DIR/QuarryFiles/scripts/split_fasta.py
mkdir -p ${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}
cp -R $SRC_DIR/QuarryFiles ${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}

#required ENV variable
mkdir -p ${PREFIX}/etc/conda/activate.d/
echo "export QUARRY_PATH=${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}/QuarryFiles" > ${PREFIX}/etc/conda/activate.d/${PKG_NAME}-${PKG_VERSION}.sh
mkdir -p ${PREFIX}/etc/conda/deactivate.d/
echo "unset QUARRY_PATH" > ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}-${PKG_VERSION}.sh
