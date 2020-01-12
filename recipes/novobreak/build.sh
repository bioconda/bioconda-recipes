#!/bin/bash

SCRIPT_REV=34cc6a500aab8480021d67eeb1ac12613dc8927e

NOPIE="-no-pie"
if [[ $target_platform == osx-64 ]]
then
    # clang does not have this flag and it is not needed there
    NOPIE=""
fi

make clean

cd samtools
make clean
make lib CC=$CC CFLAGS="-g -Wall -O2 $NOPIE" INCLUDES=-I$PREFIX/include LIBPATH=-L$PREFIX/lib
cd ..

make novoBreak INCLUDE="-Isamtools -I$PREFIX/include" LIBPATH="-Lsamtools -L$PREFIX/lib" CC=$CC CFLAGS="-g -W -Wall -O3 -finline-functions -D_FILE_OFFSET_BITS=64 $NOPIE"
mkdir -p $PREFIX/bin
cp novoBreak $PREFIX/bin

# add scripts from nb_distribution
for script in fetch_discordant.pl filter_sv.bak.pl filter_sv.pl filter_sv2.pl filter_sv_icgc.pl group_bp_reads.pl infer_bp.pl infer_bp_v4.pl infer_sv.pl run_novoBreak.sh run_ssake.pl
do
    target=$PREFIX/bin/$script
    curl -L https://raw.githubusercontent.com/czc/nb_distribution/$SCRIPT_REV/$script > $target
    chmod +x $target
done

# add a simplified overall wrapper
run_novobreak=$PREFIX/bin/run_novobreak
echo "#!/bin/sh" > $run_novobreak
echo "run_novoBreak.sh \$(dirname \`which novoBreak\`) \$@" >> $run_novobreak
chmod +x $run_novobreak
