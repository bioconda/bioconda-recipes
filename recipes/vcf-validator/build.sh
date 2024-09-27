# Install additional dependencies
if [ -z ${OSX_ARCH+x} ]; then
  ./install_dependencies.sh linux
  mkdir build
  cd build
  cmake -G "Unix Makefiles" ..
else
  ./install_dependencies.sh osx
  mkdir build
  cd build
  cmake -G "Unix Makefiles" ..
fi
make -j2
cd ..
./build/bin/test_validation_suite
echo "Done with vcf-validator"