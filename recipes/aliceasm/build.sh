mkdir -p $PREFIX/bin

mkdir build
cd build/
cmake ..
make

cp -r ./aliceasm $PREFIX/bin
cp -r ./graphunzip $PREFIX/bin
cp -r ./reduce $PREFIX/bin
cp -r ../bcalm/scripts/convertToGFA.py $PREFIX/bin
