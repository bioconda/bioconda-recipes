# the flags the new gxx activate script sets breaks the build, so unset them here
unset CXXFLAGS
export CXXFLAGS="-I${PREFIX}/include"
mkdir -pv $PREFIX/bin/blast/bin
sed -i 's/g++/$CXX/g' source/uchime_src/mk
make -j 2
cp {mothur,uchime} $PREFIX/bin
ln -s $PREFIX/bin/{bl2seq,formatdb,blastall,megablast} $PREFIX/bin/blast/bin/
