make
g++ -std=c++11 -O2 -I include -o TREE-QMC src-tqmc/*.cpp bin/MQLib.a
mkdir -p $PREFIX/bin
cp TREE-QMC $PREFIX/bin/
chmod a+x $PREFIX/bin/TREE-QMC
