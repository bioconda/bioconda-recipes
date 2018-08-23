# as explained by the authors

# Download and extract DASTool.zip archive:
unzip DAS_Tool.v1.1.zip
cd ./DAS_Tool.v1.1

# Install R-packages:
R CMD INSTALL ./package/DASTool_1.1.0.tar.gz

# Download latest SCG database:
wget http://banfieldlab.berkeley.edu/~csieber/db.zip
unzip db.zip -d db

# Run DAS Tool:
./DAS_Tool -h
