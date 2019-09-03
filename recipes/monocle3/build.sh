monocle_version=0.1.2
export TAR=$(which tar)
export R_GZIPCMD=$(which gzip)
export R_BZIPCMD=$(which bzip2)
export LANG=en_US.UTF-8

Rscript -e 'devtools::install_github("cole-trapnell-lab/monocle3", ref="'$monocle_version'", upgrade="never")'
mkdir -p $PREFIX/bin
cp exec/monocle3 $PREFIX/bin
$R CMD INSTALL --build .
