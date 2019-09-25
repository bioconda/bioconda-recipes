### Altering scripts to use conda MetaGeneAnnotator binary
## Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl
sed "s;mga_linux_ia64;mga;" Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl > Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl.tmp && mv Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl.tmp Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl
sed "s;mga_linux_ia64\\\n;mga\\\n;" Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl > Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl.tmp && mv Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl.tmp Scripts/Step_1_contigs_cleaning_and_gene_prediction.pl
## Scripts/Step_first_add_custom_phage_sequence.pl
sed "s;mga_linux_ia64;mga;" Scripts/Step_first_add_custom_phage_sequence.pl > Scripts/Step_first_add_custom_phage_sequence.pl.tmp && mv Scripts/Step_first_add_custom_phage_sequence.pl.tmp Scripts/Step_first_add_custom_phage_sequence.pl


### Reconfiguring compiler for VirSorter Makefile
cd Scripts/
sed 's/gcc/\$\(CC\)/g' Makefile > Makefile.tmp && mv Makefile.tmp Makefile


### Compiling programs
make clean
make


### Organizing executables
cd ../

PKG_OUTDIR="${PREFIX}"/share/"${PKG_NAME}"-"${PKG_VERSION}"-"${PKG_BUILDNUM}"/
mkdir -pv "${PKG_OUTDIR}"/ "${PREFIX}"/bin/
cp -r $(ls | grep -v "conda" | grep -v "build") "${PKG_OUTDIR}"/

ln -s "${PKG_OUTDIR}"/wrapper_phage_contigs_sorter_iPlant.pl "${PREFIX}"/bin/
ln -s "${PKG_OUTDIR}"/Scripts/ "${PREFIX}"/bin/Scripts



### Fixing permissions

chmod 644 "${PKG_OUTDIR}"/Scripts/Makefile "${PKG_OUTDIR}"/Scripts/Sliding_windows_3.c "${PKG_OUTDIR}"/Scripts/Sliding_windows_3.o
chmod 755 $(find "${PKG_OUTDIR}"/Scripts/ -maxdepth 1 \( -regex ".*Step.*" -o -regex ".*Sliding_windows_3" \))
