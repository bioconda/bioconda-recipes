#!/bin/bash
set -eu

perl -pi -e 'print "#!/opt/anaconda1anaconda2anaconda3/bin/python\n" if $. == 1' vcf2db.py
chmod a+x vcf2db.py
mkdir -p $PREFIX/bin
cp vcf2db.py $PREFIX/bin
