#!/bin/bash 

PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${CONDA_PREFIX}/lib/pkgconfig
for dir in $(ld --verbose|grep SEARCH_DIR|sed -e 's/SEARCH_DIR("//g' -e 's/");//g'); do
        ret=$(ls -1 ${dir} 2>/dev/null|grep libpthread)
        if [[ $ret ]]; then
                >&2 echo libpthread in ${dir}
                >&2 echo ======================================
                >&2 echo ${ret}
        fi
done;
exit 1
./autogen.sh
./configure --prefix=$PREFIX 
make
find src -maxdepth 1 -perm +111 -exec strip {} \;
make install


