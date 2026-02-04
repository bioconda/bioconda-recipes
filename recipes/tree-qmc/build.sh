cd external/MQLib
sed -i.bak "s#g++#${CXX}#" Makefile
make
cd ../..
$CXX -std=c++11 -O2 \
    -I external/MQLib/include -I external/toms743 \
    -o tree-qmc \
    src/*.cpp external/toms743/toms743.cpp \
    external/MQLib/bin/MQLib.a -lm \
    -DVERSION=\"$(cat version.txt)\"
mkdir -p $PREFIX/bin
cp tree-qmc $PREFIX/bin/
chmod a+x $PREFIX/bin/tree-qmc
