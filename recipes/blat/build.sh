export MACHTYPE=$(uname -m)
export CFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
export HOME=${PREFIX}
mkdir -pv ${PREFIX}/bin/${MACHTYPE}
mkdir -pv ${SRC_DIR}/lib/${MACHTYPE}
(cd lib && make CC=$CC)
(cd jkOwnLib && make CC=$CC)
(cd blat && make CC=$CC)
cp ${PREFIX}/bin/${MACHTYPE}/* ${PREFIX}/bin
rm -rf ${PREFIX}/bin/${MACHTYPE}
