#!/bin/bash
# stop on error
set -eu -o pipefail

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OUT="${PREFIX}/share/${VERSION}"

# configure the test examples in fast run mode
#cd "${OUT}/helper_scripts" && configureExamples.sh -f -i "${OUT}"
# ensure that sleep module is in the right place
TMP_MODULE_DIR="${OUT}/myCustomFolder/"
mkdir -p "${TMP_MODULE_DIR}"
cp -r "${OUT}/modules/sleep" "${TMP_MODULE_DIR}/."
${OUT}/core_lib/wrapper/sedinline "s#<folder>/home/TODO/additionalModules/</folder>##" "${OUT}/examples/example_include.xml"
${OUT}/core_lib/wrapper/sedinline "s#/home/TODO/additionalModules#${TMP_MODULE_DIR}#" "${OUT}/examples/example_include.xml"

# basic test
watchdog-cmd --help 2>&1 1> /dev/null
exit 0
