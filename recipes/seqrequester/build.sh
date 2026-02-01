cd src/
# Remove multithreading for Mac OS
if [ "$(uname)" == "Darwin" ]; then
	sed -i -e "s|ENABLE_MULTITHREAD = -Denablemultithread|#ENABLE_MULTITHREAD = -Denablemultithread|g" Makefile
fi
make
BN=$PREFIX/bin
mkdir -p $BN
cp $SRC_DIR/build/bin/seqrequester $BN/
