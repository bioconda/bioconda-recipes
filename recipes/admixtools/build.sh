# clear out pre-built objects and executables
cd src
make clobber

make CFLAGS="-Wno-unused-comparison -Wno-return-type -I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" all

# Install
mkdir -p $PREFIX/bin
cp {qp3Pop,qpDstat,qpF4ratio,qpAdm,qpWave,dowtjack,expfit.sh,qpBound,qpGraph,qpreroot} $PREFIX/bin/
cp {qpff3base,qpDpart,qp4diff,qpF4ratio,qpgbug,grabpars,rolloff,rolloffp,convertf,mergeit} $PREFIX/bin/