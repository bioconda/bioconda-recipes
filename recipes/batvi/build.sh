export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
mkdir -p $PREFIX/bin/msapipeline/msa
mkdir -p $PREFIX/bin/bin
mkdir -p $PREFIX/bin/BatMis-3.00/bin
mkdir -p $PREFIX/bin/batindel/src
./build.sh
cp *.{sh,pl} $PREFIX/bin
cp bin/*.{sh,pl} $PREFIX/bin/bin
cp bin/cluster_bp $PREFIX/bin/bin
cp msapipeline/*.{sh,pl} $PREFIX/bin/msapipeline
cp msapipeline/msa/*.class $PREFIX/bin/msapipeline/msa
cp BatMis-3.00/bin/* $PREFIX/bin/BatMis-3.00/bin
cp batindel/src/penguin $PREFIX/bin/batindel/src
