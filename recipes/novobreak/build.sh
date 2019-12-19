#!/bin/bash

make clean
make novoBreak LIBPATH=-L$PREFIX/lib INCLUDE=-I$PREFIX/include CC=$CC CFLAGS=-g -W -Wall -O3 -finline-functions -D_FILE_OFFSET_BITS=64 -fPIE
mkdir -p $PREFIX/bin
cp novoBreak $PREFIX/bin

# add scripts from nb_distribution
for script in fetch_discordant.pl filter_sv.bak.pl filter_sv.pl filter_sv2.pl filter_sv_icgc.pl group_bp_reads.pl infer_bp.pl infer_bp_v4.pl infer_sv.pl run_novoBreak.sh run_ssake.pl
do
    target=$PREFIX/bin/$script
    curl -L https://raw.githubusercontent.com/czc/nb_distribution/923c670/$script > $target
    chmod +x $target
done

# add a simplified overall wrapper
run_novobreak=$PREFIX/bin/run_novobreak
echo "#!/bin/sh" > $run_novobreak
echo "run_novoBreak.sh \$(dirname \`which novoBreak\`) \$@" >> $run_novobreak
chmod +x $run_novobreak
