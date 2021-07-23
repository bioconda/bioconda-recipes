#! /bin/bash

#create directory following bioconda rules
appspam_dir="${SRC_DIR}/opt/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $appspam_dir

mkdir -p build
cd build
cmake ..
make

#link in /bin, following bioconda rules
install -d ${PREFIX}/bin
install appspam ${PREFIX}/bin/
