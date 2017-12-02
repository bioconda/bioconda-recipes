#!/bin/bash
# stop on error
set -eu -o pipefail

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OUT="${PREFIX}/share/${VERSION}"
PATH="$PATH:$OUT/core_lib/wrapper/"

# found at: http://stackoverflow.com/questions/601543/command-line-command-to-auto-kill-a-command-after-a-certain-amount-of-time
function timeoutperl() { perl -e 'alarm shift; exec @ARGV' "$@"; }

# basic test
timeoutperl 5 watchdog-cmd --help 2>&1 1> /dev/null;

# prepare workflow test
TEST_FILE="workflow.test.xml"
sedinline "s#BASE_DIR#${OUT}/#" "${TEST_FILE}"

# workflow test
timeoutperl 10 watchdog-cmd -mailWaitTime 0 -x "${TEST_FILE}" -p 8616 2>&1 1> /dev/null
exit 0
