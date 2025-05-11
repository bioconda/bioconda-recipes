set -xe

mkdir -p test/build
cd test/build

#export CONDA_PREFIX=$PREFIX

cmake -DCMAKE_MODULE_PATH="${CONDA_PREFIX}/share/cmake/Modules" ..
make

ls -al
./test
