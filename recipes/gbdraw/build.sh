
# Install the Python package
$PYTHON -m pip install . --no-deps --ignore-installed -vv

# Create the fonts directory in the Conda environment
mkdir -p $PREFIX/fonts

# Copy the TTF font files to the Conda environment's fonts directory
cp gbdraw/data/*.ttf $PREFIX/fonts/
