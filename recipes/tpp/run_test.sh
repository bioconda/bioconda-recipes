#!/usr/bin/env bash

#-- BEGIN set up testing environment ----------------------------------------#

git clone https://github.com/jvolkening/conda_test_data
cd conda_test_data
git fetch --all --tags --prune
git checkout bioconda-tpp-5.0.0-0

. util/assert.sh
cd channels/bioconda/tpp

#-- END set up testing environment ------------------------------------------#


# These commands aren't tested yet

#ASAPRatioPvalueParser
#CompactParser
#DiscoFilter
#PeptideMapper
#RTCalc
#Sequest2XML
#RTCatalogParser


Out2XML test 1
assert_lines test.pep.xml 2484

Sqt2XML -p test/sequest.params test.sqt
assert_lines test.pep.xml 2945

Mascot2XML test.dat -Etrypsin -Dtest.faa -Rtest.mzML -Otest -nodat -notgz
assert_lines test.pep.xml 1261

xinteract -p0 -OAPtudF -Nfoo -dREV_ -Dtest.faa test.pep.xml
assert_lines interact-foo.pep.xml 3532

DatabaseParser test.pep.xml > db.path
assert_lines db.path 1

PeptideProphetParser test.pep.xml DECOY=REV_
assert_lines test.pep.xml 1458

InteractParser interact.pep.xml -Dtest.faa -W test.pep.xml
assert_lines interact.pep.xml 1464

InterProphetParser DECOY=REV_ NONSP interact.pep.xml iprophet.pep.xml
assert_lines iprophet.pep.xml 1546

RefreshParser iprophet.pep.xml test.faa
assert_lines iprophet.pep.xml 1549

ProteinProphet iprophet.pep.xml test.prot.xml
assert_lines test.prot.xml 372

RespectParser iprophet.pep.xml
assert_lines test_rs.mzML 1898

ASAPRatioPeptideParser iprophet.pep.xml
assert_lines iprophet.pep.xml 1739

ASAPRatioProteinRatioParser test.prot.xml
assert_lines test.prot.xml 510

XPressPeptideParser iprophet.pep.xml
assert_lines iprophet.pep.xml 1766

XPressProteinRatioParser test.prot.xml
assert_lines test.prot.xml 531

StPeter test.prot.xml
assert_lines test.prot.xml 534

CombineOut test test foo

LibraPeptideParser iprophet.pep.xml -clibra_tmt10.xml
assert_lines iprophet.pep.xml 2299

LibraProteinRatioParser test.prot.xml -clibra_tmt10.xml
assert_lines quantitation.tsv 56

PTMProphetParser iprophet.pep.xml
assert_lines iprophet.pep.xml 2307

MzXML2Search -mgf test.mzML
assert_lines test.mgf 16262

Q3ProteinRatioParser test.prot.xml
assert_lines test.prot.xml 1027

# these are programs used by GalaxyP
decoyFASTA test.faa decoy.faa
assert_lines decoy.faa 2105

digestdb test.faa > digest.txt
assert_lines digest.txt 7443

PepXMLViewer.cgi -I test.pep.xml -B exportSpreadsheet 1
assert_lines test.pep.xls 30

Tandem2XML test.t.xml test.pep.xml
assert_lines test.pep.xml 720

echo "All tests ran successfully"

exit 0
