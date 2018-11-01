export SMR_HOME=$PREFIX
mkdir -pv $PREFIX/bin
mkdir -p build
cd build
cmake -G "Unix Makefiles" -D CMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DSRC_ROCKSDB=1 -DSET_ROCKSDB=1 ../
cp $SMR_HOME/build/src/indexdb $PREFIX/bin
cp $SMR_HOME/build/src/sortmerna $PREFIX/bin
cp $PREFIX/scripts/{merge-paired-reads.sh,unmerge-paired-reads.sh}  $PREFIX/bin
