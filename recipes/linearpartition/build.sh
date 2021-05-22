# Build
CC=$GXX
make -e

# Install
mkdir -p $PREFIX/shared/linearpartition
mkdir -p $PREFIX/bin

cp -r bin/ linearpartition AUTHORS draw_heatmap $PREFIX/shared/linearpartition/
ln -sr $PREFIX/shared/linearpartition/linearpartition $PREFIX/bin/linearpartition
ln -sr $PREFIX/shared/linearpartition/draw_heatmap $PREFIX/bin/draw_heatmap

