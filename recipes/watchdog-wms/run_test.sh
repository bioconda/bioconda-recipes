#!/bin/bash
# stop on error
set -eu -o pipefail

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OUT="${PREFIX}/share/${VERSION}"
PATH="$PATH:$OUT/core_lib/wrapper/"

function timeoutbash() { bash -c '(sleep 180; kill -9 $$ 2>/dev/null) & exec $@' $0 $@; }

# basic test
timeoutbash watchdog-cmd --help 2>&1>/dev/null

# prepare workflow test
TEST_FILE="workflow.test.xml"
sedinline "s#BASE_DIR#${OUT}/#" "${TEST_FILE}"
# workflow test
timeoutbash watchdog-cmd -mailWaitTime 0 -x "${TEST_FILE}" -p 8616 2>&1>/dev/null
echo "Finished Watchdog sleep test!"
exit 0
