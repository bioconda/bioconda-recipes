### Reconfiguring compiler for VirSorter Makefile
cd Scripts/
sed 's/gcc/\$\(GCC\)/g' Makefile > Makefile.tmp && mv Makefile.tmp Makefile


### Compiling programs
make clean
make


### Organizing executables
cd ../
PKG_OUTDIR="${PREFIX}"/share/"${PKG_NAME}"-"${PKG_VERSION}"-"${PKG_BUILDNUM}"
mkdir -pv "${PREFIX}"/bin "${PKG_OUTDIR}"
ls -a
pwd
cp -r ./ "${PREFIX}"/share/
ln -s "${PKG_OUTDIR}"/wrapper_phage_contigs_sorter_iPlant.pl "${PREFIX}"/bin/
