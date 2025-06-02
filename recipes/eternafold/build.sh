# Move to conda-specific src directory location
cd $SRC_DIR/src

# Build Eternafold
make CXX=$CXX

# Move built binaries to environment-specific location
mkdir -p -v $PREFIX/bin/eternafold-bin
cp contrafold api_test score_prediction $PREFIX/bin/eternafold-bin

# Move relevant repo files to lib folder
cd $PREFIX
mkdir -p -v $PREFIX/lib/eternafold-lib
cp -R $SRC_DIR/* $PREFIX/lib/eternafold-lib

# Symlink binary as eternafold and place in PATH-available location
ln -s $PREFIX/bin/eternafold-bin/contrafold $PREFIX/bin/eternafold

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p -v "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done