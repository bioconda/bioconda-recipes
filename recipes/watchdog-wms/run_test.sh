#!/bin/bash
# stop on error
set -eu -o pipefail

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
OUT="${PREFIX}/share/${VERSION}"

# configure the test examples in fast run mode
#cd "${OUT}/helper_scripts" && configureExamples.sh -f -i "${OUT}"
# ensure that sleep module is in the right place
#TMP_MODULE_DIR="${OUT}/myCustomFolder/"
#mkdir -p "${TMP_MODULE_DIR}"
#cp -r "${OUT}/modules/sleep" "${TMP_MODULE_DIR}/."
#${OUT}/core_lib/wrapper/sedinline "s#<folder>/home/TODO/additionalModules/</folder>##" "${OUT}/examples/example_include.xml"
#${OUT}/core_lib/wrapper/sedinline "s#/home/TODO/additionalModules#${TMP_MODULE_DIR}#" "${OUT}/examples/example_include.xml"

# set some variables required for testing
#LOG_BASE_PLAIN=$(mktemp -d)
#touch "${LOG_BASE_PLAIN}"
#LOG_BASE="${LOG_BASE_PLAIN}/watchdog.install.test."
#START_PORT=9000
#INSTALL_DIR="${OUT}"

#echo "Testing bioconda installation of Watchdog..."
#echo "Log files can be found in ${LOG_BASE}*.log if tests fail!" 

#FAIL=0
# basic test
watchdog-cmd --help 2>&1 1> "${LOG_BASE}1.log"

# test all XML examples in parallel
#I=2
#cd "${INSTALL_DIR}/examples"
#for F in `ls example_*.xml 2>/dev/null`; 
#do
#	watchdog-cmd -disableCheckpoint -mailWaitTime 0 -x "${INSTALL_DIR}/examples/${F}" -p $START_PORT 2>&1 1> "${LOG_BASE}${I}.log"
#	if [ "$?" -ne "0" ]; then
#		echo "[FAILED TEST] Test for '$F' failed!"
#		FAIL=1
#	fi
#	START_PORT=$((START_PORT+1))
#	I=$((I+1))
#done
#if [ "$FAIL" -eq "0" ]; then
#	echo "[PASSED TESTS] All ${I} tests had a exit code of 0. Deleting log test files..."
#	rm "${LOG_BASE_PLAIN}"/*.log
#	rm -r "${LOG_BASE_PLAIN}"
#fi
#rm -r "${TMP_MODULE_DIR}"
