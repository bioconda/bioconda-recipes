mkdir -pv ${PREFIX}/bin
make -C sumatra
make -C sumaclust
cp {sumatra/sumatra,sumaclust/sumaclust} ${PREFIX}/bin
