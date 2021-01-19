export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export BOOST_INCLUDE=$PREFIX/include
export LD_LIBRARY_PATH="${PREFIX}/lib"

cd ./src
COMPILER=${CXX} make

cp ./purge_dups ${PREFIX}/bin/purge_dups
cp ./split_fa ${PREFIX}/bin/split_fa
cp ./pbcstat ${PREFIX}/bin/pbcstat
cp ./ngscstat ${PREFIX}/bin/ngscstat
cp ./calcuts ${PREFIX}/bin/calcuts
cp ./get_seqs ${PREFIX}/bin/get_seqs


chmod +x ${PREFIX}/bin/purge_dups
chmod +x ${PREFIX}/bin/split_fa
chmod +x ${PREFIX}/bin/pbcstat
chmod +x ${PREFIX}/bin/ngscstat
chmod +x ${PREFIX}/bin/calcuts
chmod +x ${PREFIX}/bin/get_seqs