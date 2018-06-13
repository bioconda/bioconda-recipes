#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib/STAR-Fusion

cp -r * $PREFIX/lib/STAR-Fusion

echo "#!/bin/bash" > $PREFIX/bin/STAR-Fusion
echo "$PREFIX/lib/STAR-Fusion/STAR-Fusion \$@" >> $PREFIX/bin/STAR-Fusion
chmod +x $PREFIX/bin/STAR-Fusion

echo "#!/bin/bash" > $PREFIX/bin/blast_and_promiscuity_filter.pl
echo "$PREFIX/lib/STAR-Fusion/FusionFilter/blast_and_promiscuity_filter.pl \$@" >> $PREFIX/bin/blast_and_promiscuity_filter.pl
chmod +x $PREFIX/bin/blast_and_promiscuity_filter.pl

echo "#!/bin/bash" > $PREFIX/bin/prep_genome_lib.pl
echo "$PREFIX/lib/STAR-Fusion/FusionFilter/prep_genome_lib.pl \$@" >> $PREFIX/bin/prep_genome_lib.pl
chmod +x $PREFIX/bin/prep_genome_lib.pl
