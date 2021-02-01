#!/bin/sh
# Compile nim
pushd nim_source

if [[ $OSTYPE == "darwin"* ]]; then
  export HOME="/Users/distiller"
  bash build.sh --os darwin --cpu x86_64
else
  bash build.sh --os linux --cpu x86_64
fi
bname=`basename $CC`
echo "gcc.exe = \"${bname}\"" >> config/nim.cfg
echo "gcc.linkerexe = \"${bname}\"" >> config/nim.cfg
echo "clang.exe = \"${bname}\"" >> config/nim.cfg
echo "clang.linkerexe = \"${bname}\"" >> config/nim.cfg
bin/nim c  koch
./koch tools
popd

export PATH=$SRC_DIR/nim_source/bin:$PATH
export LD_LIBRARY_PATH=$PREFIX/lib

nimble install -y --verbose
mkdir -p $PREFIX/bin
for BIN in covtobed covtotarget covtocounts;
do
  chmod a+x src/${BIN}
  cp ${BIN} "$PREFIX"/bin/${BIN}
done