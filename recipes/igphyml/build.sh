#!/bin/bash
set -x
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/igphyml

aclocal
autoheader
autoconf -f
automake -f --add-missing
./configure

cp -r examples ${PREFIX}/share/igphyml
pushd src
cp -r motifs ${PREFIX}/share/igphyml

for f in *.c ; do
  o=${f%%.c}.o;
  $CC -DUNIX -DPHYML -DOMP -DDEBUG -DNBLAS -I. $CFLAGS -fopenmp -DHTABLE="\"../share/igphyml\"" $LDFLAGS -c -o $o $f
done

$CC -fopenmp $CFLAGS $LDFLAGS -o ${PREFIX}/bin/igphyml main.o utilities.o optimiz.o lk.o bionj.o models.o free.o help.o simu.o eigen.o pars.o alrt.o controller.o cl.o spr.o stats.o nucle2codon.o io.o -lm

mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/igphyml.sh
export IGPHYML_PATH=${PREFIX}/share/igphyml/motifs/
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/igphyml.sh
unset IGPHYML_PATH
EOF
