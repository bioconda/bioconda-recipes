cd MQLib
make \
    GXX="${CXX}" \
    AR="${AR}"
cd ..
$CXX -std=c++11 -O2 -I MQLib/include -o TREE-QMC src/*.cpp MQLib/bin/MQLib.a
mkdir -p $PREFIX/bin
cp TREE-QMC $PREFIX/bin/
chmod a+x $PREFIX/bin/TREE-QMC
