#!/bin/bash

PKG_FULL_HOME_PATH="${PREFIX}/share/${PKG_NAME}"
PKG_LAUNCHER="${PKG_FULL_HOME_PATH}/bin/scala-launcher"

mkdir -vp ${PREFIX}/bin;
mkdir -vp ${PREFIX}/share;

cp -va ${SRC_DIR} ${PREFIX}/share || exit 1;

pushd ${PREFIX}/share || exit 1;
ln -sv ${PKG_NAME}-${PKG_VERSION} ${PKG_NAME} || exit  1;
popd || exit 1;

cat > ${PKG_LAUNCHER} <<EOF
#!/bin/bash

CWD="\$(cd "\$(dirname "\${0}")" && pwd -P)"
CMD="\$(basename "\${0}")"

export SCALA_HOME="\$(cd "\${CWD}/../share/${PKG_NAME}" && pwd -P)"

echo -e ""
echo -e "Setting up SCALA_HOME for scala to \${SCALA_HOME} ..."
if [[ -z \${@} ]]; then
    echo -e "Launching \${CMD}"
    echo -e ""
    \${SCALA_HOME}/bin/\${CMD}
else
    echo -e "Launching \${CMD} \"\${@}\""
    echo -e ""
    \${SCALA_HOME}/bin/\${CMD} "\${@}"
fi
EOF

chmod 755 ${PKG_LAUNCHER} || exit 1;

BIN_ITEM_LIST="$(cd ${PKG_FULL_HOME_PATH}/bin && ls * 2>/dev/null)"

pushd ${PREFIX}/bin/ || exit 1;
for item in ${BIN_ITEM_LIST}; do
    ln -vs ../share/${PKG_NAME}/bin/scala-launcher ${item} || exit 1;
done
rm -v ${PREFIX}/bin/scala-launcher || exit 1;
popd || exit 1;
