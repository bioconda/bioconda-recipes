#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

# Always build PIC code for enable static linking into other shared libraries
export CXXFLAGS="${CXXFLAGS} -fPIC"

ls -l $PREFIX/include/

mkdir -p $PREFIX/web
mkdir -p $PREFIX/cgi-bin
mkdir -p $PREFIX/params

sed -i.bak s/endform/end_form/g trans_proteomic_pipeline/CGI/ProtXMLViewer.pl

rm trans_proteomic_pipeline/extern/htmldoc.tgz
rm trans_proteomic_pipeline/extern/htmldoc -rf
cd trans_proteomic_pipeline/src/

echo "TPP_ROOT=${PREFIX}/" >> Makefile.config.incl
echo "TPP_WEB=${PREFIX}/web/" >> Makefile.config.incl
echo "CGI_USERS_DIR=${PREFIX}/cgi-bin/" >> Makefile.config.incl
echo "HTMLDOC_BIN=" >> Makefile.config.incl
#echo "LINK=shared" >> Makefile.config.incl
#echo "LIBEXT=so" >> Makefile.config.incl

echo "GNUPLOT_BINARY=${PREFIX}/bin/gnuplot" >> Makefile.config.incl
echo "XSLT_PROC=${PREFIX}/bin/xsltproc" >> Makefile.config.incl

sed -i.bak 's/^HTMLDOC_/#HTMLDOC_/g' Makefile.incl
sed -i.bak 's|^GD_INCL.*|GD_INCL= -I ${PREFIX}/include/|g' Makefile.incl
sed -i.bak 's|--with-thread stage|--with-thread stage include="${INCLUDE_PATH}" cxxflags="${CXXFLAGS}"|g' Makefile.incl

make 
make install
