#!/bin/bash

package_home="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${package_home}"
cp -aR * "${package_home}/"

dest_file=${package_home}/clinker
sed \
    's|\$PACKAGE_HOME|'"${package_home}"'|g' \
    "${RECIPE_DIR}/clinker-wrapper.sh" \
    > "${dest_file}"
chmod +x "${dest_file}"

mkdir -p "${PREFIX}/bin"
ln -s "${dest_file}" "${PREFIX}/bin/"
