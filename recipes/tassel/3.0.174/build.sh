BINARY_HOME=$PREFIX/bin
TASSEL_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Copy source to the conda environment
mkdir -p $TASSEL_HOME
cp -R $SRC_DIR/* $TASSEL_HOME//

# Create symbolic links for TASSEL's wrappers
ln -s $TASSEL_HOME/run_anything.pl $BINARY_HOME/
ln -s $TASSEL_HOME/run_pipeline.pl $BINARY_HOME/
ln -s $TASSEL_HOME/start_tassel.pl $BINARY_HOME/