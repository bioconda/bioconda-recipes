BIN_FOLDER=$PREFIX/bin
mkdir -p $BIN_FOLDER

wget $URL
tar -xzf pilercr${PKG_VERSION}.tar.gz

cd pilercr${PKG_VERSION}
make

cp pilercr $BIN_FOLDER/pilercr
