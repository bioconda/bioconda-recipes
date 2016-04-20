#!/bin/sh
make
mkdir -p $PREFIX/bin
mkdir -p ${PREFIX}/share/snap
mkdir -p ${PREFIX}/share/snap/bin
cp -p snap fathom forge hmm-info exonpairs cds-trainer.pl hmm-assembler.pl noncoding-trainer.pl patch-hmm.pl zff2gff3.pl $PREFIX/share/snap/bin
cp -pr HMM ${PREFIX}/share/snap
cp -pr DNA ${PREFIX}/share/snap

cat <<EOF >> ${PREFIX}/bin/snap
#!/bin/sh

SNAPDIR=${PREFIX}/share/snap
NAME=\`basename \$0\`

ZOE=\$SNAPDIR
export ZOE

\${SNAPDIR}/bin/\$NAME \$@
EOF
chmod a+x ${PREFIX}/bin/snap

for NAME in fathom forge hmm-info exonpairs cds-trainer.pl hmm-assembler.pl noncoding-trainer.pl patch-hmm.pl zff2gff3.pl ; do
  ln -s ${PREFIX}/bin/snap ${PREFIX}/bin/${NAME}
done
