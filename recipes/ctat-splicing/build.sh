mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/bin/prep_genome_lib

cp STAR_to_cancer_introns.py ${PREFIX}/bin/
cp prep_genome_lib/ctat-splicing-lib-integration.py ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/STAR_to_cancer_introns.py
chmod +x ${PREFIX}/bin/ctat-splicing-lib-integration.py

ln -s ${PREFIX}/bin/STAR_to_cancer_introns.py ${PREFIX}/bin/STAR_to_cancer_introns
ln -s ${PREFIX}/bin/ctat-splicing-lib-integration.py ${PREFIX}/bin/ctat-splicing-lib-integration

mkdir -p ${PREFIX}/bin/util
mkdir -p ${PREFIX}/bin/util/misc
mkdir -p ${PREFIX}/bin/util/PerlLib
mkdir -p ${PREFIX}/bin/PyLib

cp util/*.{py,pl} ${PREFIX}/bin/util/
cp prep_genome_lib/util/*.pl ${PREFIX}/bin/util/
cp util/misc/igv.tracks.json ${PREFIX}/bin/util/misc/

cp PyLib/*.py ${PREFIX}/bin/PyLib/

cp util/PerlLib/*.pm ${PREFIX}/bin/util/PerlLib/
cp prep_genome_lib/util/PerlLib/*.pm ${PREFIX}/bin/util/PerlLib/

make