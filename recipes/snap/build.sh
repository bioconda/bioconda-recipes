#!/bin/sh
cd Zoe
make CC=${CC} CFLAGS="$CFLAGS" zoe-loop
cd ..
make CC=${CC} CFLAGS="$CFLAGS" snap
make CC=${CC} CFLAGS="$CFLAGS" fathom
make CC=${CC} CFLAGS="$CFLAGS" forge
make CC=${CC} CFLAGS="$CFLAGS" hmm-info
make CC=${CC} CFLAGS="$CFLAGS" exonpairs

mkdir -p $PREFIX/bin
mkdir -p ${PREFIX}/share/snap
mkdir -p ${PREFIX}/share/snap/bin
for perl_script in cds-trainer.pl hmm-assembler.pl noncoding-trainer.pl patch-hmm.pl zff2gff3.pl; do
  sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${perl_script}
done
cp -p snap fathom forge hmm-info exonpairs cds-trainer.pl hmm-assembler.pl noncoding-trainer.pl patch-hmm.pl zff2gff3.pl $PREFIX/share/snap/bin
cp -pr HMM ${PREFIX}/share/snap
cp -pr DNA ${PREFIX}/share/snap

cat <<EOF >> ${PREFIX}/bin/snap
#!/bin/bash

SNAPDIR=/opt/anaconda1anaconda2anaconda3/share/snap
NAME=\`basename \$0\`

ZOE=\$SNAPDIR
export ZOE
echo "SNAPDIR \${SNAPDIR} NAME \${NAME}"
\${SNAPDIR}/bin/\$NAME "\$@"
EOF
chmod a+x ${PREFIX}/bin/snap

for NAME in fathom forge hmm-info exonpairs cds-trainer.pl hmm-assembler.pl noncoding-trainer.pl patch-hmm.pl zff2gff3.pl ; do
  ln -s ${PREFIX}/bin/snap ${PREFIX}/bin/${NAME}
done
