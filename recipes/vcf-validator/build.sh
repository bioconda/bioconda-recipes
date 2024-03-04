# Install additional dependencies
if [ -z ${OSX_ARCH+x} ]; then
  bash install_dependencies.sh linux
else
  bash install_dependencies.sh osx
fi
mkdir build
cd build
if [ -z ${OSX_ARCH+x} ]; then
  cmake -G "Unix Makefiles" -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc -DDEFAULT_EXT_LIB_PATH=${BUILD_PREFIX} ..
else
  cmake -G "Unix Makefiles" -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DEXT_LIB_PATH=${BUILD_PREFIX} ..
fi
make -j2
cd ..
./build/bin/test_validation_suite
echo "Done with vcf-validator"