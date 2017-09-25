#!/usr/bin/env bash

# These commands aren't tested yet

#ASAPRatioPvalueParser
#CompactParser
#DiscoFilter
#PeptideMapper
#RTCalc
#Sequest2XML
#Tandem2XML
#xinteract

# These are tests using actual input files (although output is currently not
# tested, just the absence of failure)

cd test_data

Out2XML test 1
Sqt2XML -p test/sequest.params test.sqt
Mascot2XML test.dat -Etrypsin -Dtest.faa -Rtest.mzML -Otest -nodat -notgz
DatabaseParser test.pep.xml
PeptideProphetParser test.pep.xml DECOY=REV_
InteractParser interact.pep.xml -Dtest.faa -W test.pep.xml
InterProphetParser DECOY=REV_ NONSP interact.pep.xml iprophet.pep.xml
RefreshParser iprophet.pep.xml test.faa
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
PTMProphetParser iprophet.pep.xml
MzXML2Search -mgf test.mzML
Q3ProteinRatioParser test.prot.xml
RTCatalogParser iprophet.pep.xml foo.rt

echo "All tests ran successfully"

exit 0
