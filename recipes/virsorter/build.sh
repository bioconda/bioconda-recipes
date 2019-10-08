### Reconfiguring/fixing VirSorter Makefile
cd Scripts/
sed 's/gcc/\$\(CC\)/g' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
sed 's/\\\.o/*\\\.o/' Makefile > Makefile.tmp && mv Makefile.tmp Makefile


### Compiling programs
make clean
make


### Cleaning up
rm Makefile Sliding_windows_3.*


### Organizing executables
cd ../
mkdir -pv "${PREFIX}"/bin/
mv wrapper_phage_contigs_sorter_iPlant.pl Scripts/ "${PREFIX}"/bin/
