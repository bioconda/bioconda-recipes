#!/usr/bin/env bash

function test_r0 {
    local status = 0
    "$@" || (status = $?)
    if [ $status -ne 0 ]; then
        exit 1
    fi
    return $status
}

function test_r1 {
    local status = 0
    "$@" || (status = $?)
    if [ $status -ne 1 ]; then
        exit 1
    fi
    return $status
}

# These commands aren't yet fully tested, but called with no argument are
# expected to print usage and return 1. We check for this but don't
# automatically bail

set +e

test_r1 "ASAPRatioPvalueParser"
test_r1 "CompactParser"
test_r1 "DiscoFilter"
test_r1 "MzXML2Search"
test_r1 "PeptideMapper"
test_r1 "PTMProphetParser"
test_r1 "Q3ProteinRatioParser"
test_r1 "RefreshParser"
test_r1 "RTCatalogParser"
test_r1 "RTCalc"
test_r1 "Sequest2XML"
test_r1 "StPeter"
test_r1 "Tandem2XML"
test_r1 "xinteract"

set -e

# These are tests using actual input files (although output is currently not
# tested, just the absence of failure)

cd test_data

Out2XML test 1 -Psequest.params
Sqt2XML test.sqt
Mascot2XML test.dat -Etrypsin -Dtest.faa -Rtest.mzML -Otest -nodat -notgz
DatabaseParser test.pep.xml
PeptideProphetParser test.pep.xml DECOY=REV_
InteractParser interact.pep.xml -Dtest.faa -W test.pep.xml
InterProphetParser DECOY=REV_ NONSP interact.pep.xml iprophet.pep.xml
ProteinProphet iprophet.pep.xml test.prot.xml
RespectParser iprophet.pep.xml
ASAPRatioPeptideParser iprophet.pep.xml
ASAPRatioProteinRatioParser test.prot.xml
XPressPeptideParser iprophet.pep.xml
XPressProteinRatioParser test.prot.xml
StPeter test.prot.xml
CombineOut test test foo
LibraPeptideParser iprophet.pep.xml -clibra_tmt10.xml
LibraProteinRatioParser test.prot.xml -clibra_tmt10.xml

echo "All tests ran successfully"

exit 0
