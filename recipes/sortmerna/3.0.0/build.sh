export SMR_HOME=$PREFIX
mkdir -pv $PREFIX/bin
mkdir -p build
cd build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DPORTABLE=1 -DWITH_ZLIB=1 -DWITH_TESTS=0 -DWITH_TOOLS=0 ../..
mkdir -p $SMR_HOME/3rdparty/rocksdb/build/Release
pushd $SMR_HOME/3rdparty/rocksdb/build/Release
cd 
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DPORTABLE=1 -DWITH_ZLIB=1 -DWITH_TESTS=0 -DWITH_TOOLS=0 ..
make
popd
make
cp $SMR_HOME/build/src/indexdb $PREFIX/bin
cp $SMR_HOME/build/src/sortmerna $PREFIX/bin
cp $PREFIX/scripts/{merge-paired-reads.sh,unmerge-paired-reads.sh}  $PREFIX/bin
