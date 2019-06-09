mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX

# Fix the version
make check_git_repository
sed -i.bak 's/GIT-NOTFOUND/'$PKG_VERSION' (Bioconda)/'  ../metabat_version.h

# Build & install
make VERBOSE=1
make install
