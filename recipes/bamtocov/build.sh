#!/bin/sh

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
fi

bname=`basename $CC`
echo "gcc.exe = \"${bname}\"" >> config/nim.cfg
echo "gcc.linkerexe = \"${bname}\"" >> config/nim.cfg
echo "clang.exe = \"${bname}\"" >> config/nim.cfg
echo "clang.linkerexe = \"${bname}\"" >> config/nim.cfg

 
export LD_LIBRARY_PATH=$PREFIX/lib

nimble install -y --verbose
mkdir -p $PREFIX/bin
for BIN in covtobed covtotarget covtocounts;
do
  chmod a+x src/${BIN}
  cp ${BIN} "$PREFIX"/bin/${BIN}
done