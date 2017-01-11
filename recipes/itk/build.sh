mkdir build
cd build

cmake \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D BUILD_SHARED_LIBS=ON \
    -D BUILD_EXAMPLES:BOOL=OFF \
    -D BUILD_TESTING:BOOL=OFF \
    -D ITK_BUILD_DEFAULT_MODULES:BOOL=ON \
    -D ITK_LEGACY_REMOVE:BOOL=OFF \
    -D ITK_LEGACY_SILENT:BOOL=OFF \
    -D ITKV3_COMPATIBILITY:BOOL=ON \
    -D ITK_USE_SYSTEM_JPEG:BOOL=ON \
    -D ITK_USE_SYSTEM_PNG:BOOL=ON \
    -D ITK_USE_SYSTEM_TIFF:BOOL=ON \
    -D ITK_USE_SYSTEM_ZLIB:BOOL=ON \
    -D ITK_USE_SYSTEM_HDF5:BOOL=ON \
    ..

VERBOSE=1 make -j$CPU_COUNT
make install

# Fix absolute path to system libaries, that are different for example on
# Ubuntu.
for config in $(find $PREFIX -name '*.cmake')
do
    sed -i s:/usr/lib64/libm.so:libm.so:g   $config
    sed -i s:/usr/lib64/libdl.so:libdl.so:g $config
    sed -i s:/usr/lib64/librt.so:librt.so:g $config
done
