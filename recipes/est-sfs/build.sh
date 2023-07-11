# clear out pre-built objects and executables


mkdir -p ${PREFIX}/bin

make

chmod +x est-sfs

cp est-sfs ${PREFIX}/bin/
