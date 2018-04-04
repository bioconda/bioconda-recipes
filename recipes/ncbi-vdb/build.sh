export ROOT=$PREFIX
mkdir -p $PREFIX/usr/include
./configure --prefix=$PREFIX/ \
	    --build=$PREFIX/share/ncbi \
            --with-ngs-sdk-prefix=$PREFIX
make install

####
# build sra-tools
####

cd $SRC_DIR
export VDB_SRCDIR=$SRC_VDB
./configure --prefix=$PREFIX \
	--build=$PREFIX/share/ncbi/ \
	--with-ncbi-vdb-sources=$SRC_VDB \
	--with-ncbi-vdb-build=$PREFIX/share/ncbi \
	--with-ngs-sdk-prefix=$PREFIX

make install
