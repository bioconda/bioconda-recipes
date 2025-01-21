#!/bin/bash

cd $PREFIX
mv $SRC_DIR $PREFIX/NGSCheckMate

mkdir -p $PREFIX/bin

cat << EOF > $PREFIX/bin/ncm.py
#!/usr/bin/env bash

export NCM_HOME=$PREFIX/NGSCheckMate
echo "Set the path to your reference file with the NCM_REF environment variable"
echo "eg. export NCM_REF=/<path>/<to>/<reference>" 
echo
python $PREFIX/NGSCheckMate/ncm.py "\$@"
EOF

cat << EOF > $PREFIX/bin/ncm_fastq.py
#!/usr/bin/env bash

export NCM_HOME=$PREFIX/NGSCheckMate
python $PREFIX/NGSCheckMate/ncm_fastq.py "\$@"
EOF

cat << EOF > $PREFIX/bin/vaf_ncm.py
#!/usr/bin/env bash

export NCM_HOME=$PREFIX/NGSCheckMate
python $PREFIX/NGSCheckMate/vaf_ncm.py "\$@"
EOF

cd $PREFIX/NGSCheckMate/ngscheckmate_fastq-source
make COMPILER=${CC} CFLAGS="${CFLAGS} -c" DFLAGS="${LDFLAGS}"
cd $PREFIX
ln -sf $PREFIX/NGSCheckMate/ngscheckmate_fastq-source/ngscheckmate_fastq $PREFIX/bin/
cat << EOF > $PREFIX/bin/makesnvpattern.pl
#!/usr/bin/env bash

export NCM_HOME=$PREFIX/NGSCheckMate
perl $PREFIX/NGSCheckMate/patterngenerator/makesnvpattern.pl "\$@"
EOF

#/usr/bin/perl is hardcoded, need to point to env
sed -i.bak 's/perl/env perl/g' $PREFIX/NGSCheckMate/patterngenerator/*.pl

cat << EOF > $PREFIX/NGSCheckMate/ncm.conf
SAMTOOLS=samtools
BCFTOOLS=bcftools
REF=\$NCM_REF
EOF
