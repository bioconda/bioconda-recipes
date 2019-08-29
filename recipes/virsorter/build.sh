### Reconfiguring compiler for VirSorter Makefile
cd Scripts/
sed 's/gcc/$CXX/g' Makefile > Makefile.tmp && mv Makefile.tmp Makefile


### Cleaning before compiling (just in case)
make clean


### Compiling programs
make


### Organizing executables
cd ../../
mkdir -pv "${PREFIX}"/share/
cp -r VirSorter-1.0.5/ "${PREFIX}"/share/
ln -s "${PREFIX}"/share/VirSorter-1.0.5/wrapper_phage_contigs_sorter_iPlant.pl "${PREFIX}"/bin/
