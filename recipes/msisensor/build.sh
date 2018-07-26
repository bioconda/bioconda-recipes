wget "https://github.com/samtools/samtools/archive/0.1.19.tar.gz"
tar xvf 0.1.19.tar.gz
cd samtools-0.1.19
make INCLUDES="-I. -I$PREFIX/include -I$PREFIX/include/ncurses" LIBCURSES="-L$PREFIX/lib -lncurses -ltinfo"
cd ..
export SAMTOOLS_DIR=samtools-0.1.19/
export CPPFLAGS="-I$PREFIX/include -I$SAMTOOLS_DIR"
export LIBS="-L$PREFIX/libi -L$SAMTOOLS_DIR"
export LD_LIBRARY_PATH=${PREFIX}/lib
make
cp msisensor $PREFIX/bin
