cd external/MQLib
make \
    GXX="${CXX}" \
    AR="${AR}"
cd ../..
$CXX -std=c++11 -O2 \
    -I external/MQLib/include -I external/toms743 \
    -o TREE-QMC \
    src/*.cpp external/toms743/toms743.cpp \
    external/MQLib/bin/MQLib.a -lm \
    -DVERSION=\"$(cat version.txt)\"
mkdir -p $PREFIX/bin
cp TREE-QMC $PREFIX/bin/
chmod a+x $PREFIX/bin/TREE-QMC
