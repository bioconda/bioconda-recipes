chmod 755 *
cd thirdparty
rm -rf gatb-core
git clone https://github.com/GATB/gatb-core.git
cd ..

#Making a build directory. This is where the executable will be stored
rm -rf build
mkdir build

cd build

#Running the cmake command from the build directory
cmake ..

#Running the make command
make -j 1

cd ..

mkdir -p "${PREFIX}/bin"
mv build/bin/ORNA "$PREFIX/bin/"
