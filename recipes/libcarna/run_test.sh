set -xe

mkdir -p test/build
cd test/build

cmake -DCMAKE_MODULE_PATH="${CONDA_PREFIX}/share/cmake/Modules" ..
make

ls -al
./test
