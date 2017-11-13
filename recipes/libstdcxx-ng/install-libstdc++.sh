set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

# libtool wants to use ranlib that is here, macOS install doesn't grok -t etc
# .. do we need this scoped over the whole file though?
export PATH=${SRC_DIR}/gcc_built/bin:${SRC_DIR}/.build/${CHOST}/buildtools/bin:${SRC_DIR}/.build/tools/bin:${PATH}

pushd ${SRC_DIR}/.build/${CHOST}/build/build-cc-gcc-final/

  make -C ${CHOST}/libstdc++-v3/src prefix=${PREFIX} install-toolexeclibLTLIBRARIES
  make -C ${CHOST}/libstdc++-v3/po prefix=${PREFIX} install

popd

mkdir -p ${PREFIX}/lib
mv ${PREFIX}/${CHOST}/lib/* ${PREFIX}/lib
mkdir -p ${PREFIX}/${CHOST}/sysroot/lib || true
symtargets=$(find ${PREFIX}/lib -name "libstdc++*.so*")
for symtarget in ${symtargets}; do
  symtargetname=$(basename ${symtarget})
  ln -s ${PREFIX}/lib/${symtargetname} ${PREFIX}/${CHOST}/sysroot/lib/${symtargetname}
done

# no static libs
find ${PREFIX}/lib -name "*\.a" -exec rm -rf {} \;
# no libtool files
find ${PREFIX}/lib -name "*\.la" -exec rm -rf {} \;

# Install Runtime Library Exception
install -Dm644 ${SRC_DIR}/.build/src/gcc-${PKG_VERSION}/COPYING.RUNTIME \
        ${PREFIX}/share/licenses/libstdc++/RUNTIME.LIBRARY.EXCEPTION
