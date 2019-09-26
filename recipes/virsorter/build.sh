### Altering scripts to use conda MetaGeneAnnotator binary
## Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl
sed "s;mga_linux_ia64;mga;" Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl > Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl.tmp && mv Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl.tmp Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl
sed "s;mga_linux_ia64\\\n;mga\\\n;" Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl > Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl.tmp && mv Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl.tmp Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl
## Scripts/Step_first_add_custom_phage_sequence.pl
sed "s;mga_linux_ia64;mga;" Scripts/Step_first_add_custom_phage_sequence.pl > Scripts/Step_first_add_custom_phage_sequence.pl.tmp && mv Scripts/Step_first_add_custom_phage_sequence.pl.tmp Scripts/Step_first_add_custom_phage_sequence.pl


### Reconfiguring/fixing VirSorter Makefile
cd Scripts/
sed 's/gcc/\$\(CC\)/g' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
sed 's/\\\.o/*\\\.o/' Makefile > Makefile.tmp && mv Makefile.tmp Makefile


### Compiling programs
make clean
make


### Cleaning up
rm Makefile Sliding_windows_3.*


### Setting permissions
chmod 775 *


### Organizing executables
cd ../
mkdir -pv "${PREFIX}"/bin/
mv wrapper_phage_contigs_sorter_iPlant.pl Scripts/ "${PREFIX}"/bin/
