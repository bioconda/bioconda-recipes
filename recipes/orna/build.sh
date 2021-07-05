
#Initializing and updating the git submodules
git submodule init;
git submodule update;

#Making a build directory. This is where the executable will be stored
rm -rf build
mkdir build

cd build

#Running the cmake command from the build directory
cmake ..

#Running the make command
make -j 10

cd ..

#mkdir -p "$PREFIX/bin"

#ln -s build/bin/ORNA "$PREFIX/bin"
