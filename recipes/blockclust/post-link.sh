wget https://github.com/bgruening/download_store/raw/master/blockclust/blockclust-data-1.0/annotations/dm3.tar.gz -P ${PREFIX}/share/blockclust_data
wget https://github.com/bgruening/download_store/raw/master/blockclust/blockclust-data-1.0/annotations/hg19.tar.gz -P ${PREFIX}/share/blockclust_data
wget https://github.com/bgruening/download_store/raw/master/blockclust/blockclust-data-1.0/annotations/mm10.tar.gz -P ${PREFIX}/share/blockclust_data
wget https://github.com/bgruening/download_store/raw/master/blockclust/blockclust-data-1.0/annotations/panTro4.tar.gz -P ${PREFIX}/share/blockclust_data
wget https://github.com/bgruening/download_store/raw/master/blockclust/blockclust-data-1.0/annotations/rheMac3.tar.gz -P ${PREFIX}/share/blockclust_data
wget https://github.com/bgruening/download_store/raw/master/blockclust/blockclust-data-1.0/annotations/celWS235.tar.gz -P ${PREFIX}/share/blockclust_data
wget https://github.com/bgruening/download_store/raw/master/blockclust/blockclust-data-1.0/annotations/tair10.tar.gz -P ${PREFIX}/share/blockclust_data
wget https://github.com/bgruening/download_store/raw/master/blockclust/blockclust-data-1.0/models.tar.gz -P ${PREFIX}/share/blockclust_data

for i in ${PREFIX}/share/blockclust_data/*.tar.gz; do tar -xf $i -C ${PREFIX}/share/blockclust_data;rm $i;done
