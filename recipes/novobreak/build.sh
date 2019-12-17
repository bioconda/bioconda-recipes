#!/bin/bash

make clean
make novoBreak LIBPATH=-L$PREFIX/lib INCLUDE=-I$PREFIX/include
mkdir -p $PREFIX/bin
cp novoBreak $PREFIX/bin
cp *.pl *.sh $PREFIX/bin

run_novobreak=$PREFIX/bin/run_novobreak
echo "#!/bin/sh" > $run_novobreak
echo "run_novoBreak.sh \`which novoBreak\` \$*" >> $run_novobreak
chmod +x $run_novobreak
