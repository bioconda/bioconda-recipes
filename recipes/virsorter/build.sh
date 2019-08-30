### Reconfiguring compiler for VirSorter Makefile
cd Scripts/
sed 's/gcc/\$\(GCC\)/g' Makefile > Makefile.tmp && mv Makefile.tmp Makefile


### Compiling programs
make clean
make


### Organizing executables
cd ../
PKG_OUTDIR="${PREFIX}"/share/"${PKG_NAME}"-"${PKG_VERSION}"-"${PKG_BUILDNUM}"/
mkdir -pv "${PKG_OUTDIR}"/ "${PREFIX}"/bin/
cp -r $(ls | grep -v "conda" | grep -v "build") "${PKG_OUTDIR}"/
ln -s "${PKG_OUTDIR}"/wrapper_phage_contigs_sorter_iPlant.pl "${PREFIX}"/bin/
