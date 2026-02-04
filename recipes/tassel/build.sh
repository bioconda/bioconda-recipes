BINARY_HOME=$PREFIX/bin 
TASSEL_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Copy source to the conda environment
mkdir -p $TASSEL_HOME 
cp -R $SRC_DIR/* $TASSEL_HOME/

# Convert CRLF in wrappers to LF
sed -i 's/\r//' $TASSEL_HOME/*.pl

# Create symbolic links for TASSEL's wrappers
mkdir -p $BINARY_HOME
ln -s $TASSEL_HOME/run_anything.pl $BINARY_HOME/ 
ln -s $TASSEL_HOME/run_pipeline.pl $BINARY_HOME/
ln -s $TASSEL_HOME/start_tassel.pl $BINARY_HOME/
