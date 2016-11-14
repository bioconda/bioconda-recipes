#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export ZLIB_INCL="${PREFIX}/include"
#export CFLAGS="-I$PREFIX/include"

cp $RECIPE_DIR/Makefile trans_proteomic_pipeline/src/Makefile

# Always build PIC code for enable static linking into other shared libraries
export CXXFLAGS="${CXXFLAGS} -fPIC"

ls -l $PREFIX/include/

mkdir -p $PREFIX/web
mkdir -p $PREFIX/cgi-bin
mkdir -p $PREFIX/params

sed -i.bak s/endform/end_form/g trans_proteomic_pipeline/CGI/ProtXMLViewer.pl

rm trans_proteomic_pipeline/extern/htmldoc.tgz
rm -rf trans_proteomic_pipeline/extern/htmldoc
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

# needed to supress long outputs that forces travis to fails (4MB limit)
sed -i.bak 's|make \$(HDF5_ENV)|make --silent \$(HDF5_ENV) 2>\&1 >/dev/null|g' Makefile.incl

#sed -i.bak 's|^ZLIB_INCL=|ZLIB_INCL=${PREFIX}/include|g' Makefile.incl
# skip make install-examples from hdf5
sed -i.bak 's|HDF5_ENV); make install|HDF5_ENV); make install-recursive|g' Makefile.incl



make #--silent 2>&1 >/dev/null
make install #--silent 2>&1 >/dev/null

# remove the webserver part to save space - could be included if needed
rm -rf $PREFIX/html/
rm -rf $PREFIX/cgi-bin/
