#!/bin/sh
# Compile nim

cp "${CC}" "${BUILD_PREFIX}/bin/gcc"

mkdir -p $PREFIX/share
mkdir -p $PREFIX/bin
cp "$RECIPE_DIR/strling.sh" "$PREFIX/share/strling.sh"
ln -s "$PREFIX/share/strling.sh" "$PREFIX/bin/strling"
chmod +x "$PREFIX/bin/strling"

pushd nimsrc
if [[ $OSTYPE == "darwin"* ]]; then
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

export PATH=$SRC_DIR/nimsrc/bin:$PATH#!/bin/sh

nimble install -y --verbose
chmod a+x strling
cp strling $PREFIX/share/strling
