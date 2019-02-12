Rscript -e 'install.packages(c("rmarkdown", "pheatmap"), repos="https://stat.ethz.ch/CRAN")'
cmake -H. -Bbuild -DCMAKE_INSTALL_PREFIX=$PREFIX
cd build
make
make install
