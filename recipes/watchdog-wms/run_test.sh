#!/bin/bash
# stop on error
set -eu -o pipefail

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OUT="${PREFIX}/share/${VERSION}"

# basic test
timeout 15s watchdog-cmd --help 2>&1 1> /dev/null

# prepare workflow test
TEST_FILE="workflow.test.xml"
sed -i "s#BASE_DIR#${OUT}/#" "${TEST_FILE}"

# workflow test
timeout 15s watchdog-cmd -mailWaitTime 0 -x "${TEST_FILE}" -p 8616 2>&1 1> /dev/null
exit 0
