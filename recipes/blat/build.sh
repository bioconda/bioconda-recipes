export MACHTYPE=$(uname -m)
export CFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
# workaround for Blat's non-standard install method
export HOME=${PREFIX}
mkdir -pv ${PREFIX}/bin/${MACHTYPE}
mkdir -pv ${SRC_DIR}/lib/${MACHTYPE}
(cd lib && make)
(cd jkOwnLib && make)
(cd blat && make)
cp ${PREFIX}/bin/${MACHTYPE}/* ${PREFIX}/bin
rm -rf ${PREFIX}/bin/${MACHTYPE}
