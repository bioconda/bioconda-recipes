mkdir build
cd build

if [ -z "$OSX_ARCH" ]
then
   config=config.cmake.linux
else
   config=config.cmake.osx
fi

sed s:CONDA_PREFIX:$PREFIX: $RECIPE_DIR/$config > config.cmake

# Configure
cmake -C config.cmake ..

# Build
make -j$CPU_COUNT

# Install
make install

# Fix absolute path to system libaries, that are different for example on
# Ubuntu.
for config in $(find $PREFIX -name '*.cmake')
do
    sed -i s:/usr/lib64/libm.so:libm.so:g   $config
    sed -i s:/usr/lib64/libdl.so:libdl.so:g $config
    sed -i s:/usr/lib64/librt.so:librt.so:g $config
done
