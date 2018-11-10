BINARY_HOME=$PREFIX/bin 
A5_MISEQ_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

# Copy source to the conda environment
mkdir -p $A5_MISEQ_HOME 
cp -R $SRC_DIR/* $A5_MISEQ_HOME/

# Create symbolic links for a5_miseq's launch script
ln -s $A5_MISEQ_HOME/bin/a5_pipeline.pl $BINARY_HOME/ 