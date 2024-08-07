# clear out pre-built objects and executables


mkdir -p ${PREFIX}/bin

make CC="${CC} -fcommon ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"

chmod +x est-sfs

cp est-sfs ${PREFIX}/bin/
