echo "
HLA*LA installed.  You still need to install the data packages and
prepare the inference graph. The following commands should do the job:

mkdir $PREFIX/opt/hla-la/graphs
cd $PREFIX/opt/hla-la/graphs
wget http://www.well.ox.ac.uk/downloads/PRG_MHC_GRCh38_withIMGT.tar.gz
tar -xvzf PRG_MHC_GRCh38_withIMGT.tar.gz

cd $PREFIX/opt/hla-la/src
wget https://www.dropbox.com/s/mnkig0fhaym43m0/reference_HLA_ASM.tar.gz
tar -xvzf reference_HLA_ASM.tar.gz

../bin/HLA-LA --action prepareGraph --PRG_graph_dir ../graphs/PRG_MHC_GRCh38_withIMGT


" > $PREFIX/.messages.txt
