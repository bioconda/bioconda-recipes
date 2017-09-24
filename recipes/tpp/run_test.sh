#!/usr/bin/env bash

function test_r0 {
    set +e
    "$@" >/dev/null 2>&1
    local status=$?
    if [ $status -ne 0 ]; then
        exit 1
    fi
    set -e
    return $status
}

function test_r1 {
    set +e
    "$@" >/dev/null 2>&1
    local status=$?
    if [ $status -ne 1 ]; then
        exit 1
    fi
    set -e
    return $status
}

# these commands are expected to return "0" if run with no arguments
test_r0 "ProteinProphet"

# these commands are expected to return "1" if run with no arguments
test_r1 "ASAPRatioPeptideParser"
test_r1 "ASAPRatioProteinRatioParser"
test_r1 "ASAPRatioPvalueParser"
test_r1 "CombineOut"
test_r1 "CompactParser"
test_r1 "DatabaseParser"
test_r1 "DiscoFilter"
test_r1 "InteractParser"
test_r1 "InterProphetParser"
test_r1 "LibraPeptideParser"
test_r1 "LibraProteinRatioParser"
test_r1 "Mascot2XML"
test_r1 "MzXML2Search"
test_r1 "Out2XML"
test_r1 "PeptideMapper"
test_r1 "PeptideProphetParser"
test_r1 "PTMProphetParser"
test_r1 "Q3ProteinRatioParser"
test_r1 "RefreshParser"
test_r1 "RespectParser"
test_r1 "RTCatalogParser"
test_r1 "RTCalc"
test_r1 "Sequest2XML"
test_r1 "StPeter"
test_r1 "Sqt2XML"
test_r1 "Tandem2XML"
test_r1 "xinteract"
test_r1 "XPressPeptideParser"
test_r1 "XPressProteinRatioParser"

# additional tests of proper functionality
Mascot2XML test.dat -Etrypsin -Dtest.faa -Rtest.mzML -Otest -nodat -notgz

echo "All tests ran successfully"

exit 0
