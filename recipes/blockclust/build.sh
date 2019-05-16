sed -i.bak "s/CXX=g++//" Makefile
make
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/blockclust_data
cp blockclust scripts/blockclust.py scripts/blockclust_plot.r ${PREFIX}/bin
cp blockclust_data/blockclust.config blockclust_data/rfam_map.txt ${PREFIX}/share/blockclust_data

