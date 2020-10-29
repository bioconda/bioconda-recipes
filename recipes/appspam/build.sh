#! /bin/bash

#create directory following bioconda rules
appspam_dir="${PREFIX}/opt/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $appspam_dir

#compile
cd $SRC_DIR
mkdir build
cd build
cmake ..
make

#link in /bin, following bioconda rules
mkdir -p ${PREFIX}/bin
ln -s ${appspam_dir}/appspam ${PREFIX}/bin/appspam
