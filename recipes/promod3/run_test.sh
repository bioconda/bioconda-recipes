pm build-model \
    -f doc/tests/data/1crn.fasta \
    -p doc/tests/data/1crn_cut.pdb \
    -s doc/tests/data/1CRNA.hhm

tail model.pdb | grep -q 'ATOM    327  OXT ASN A  46'
tail model.pdb | grep -q 'TER     328      ASN A  46'
tail model.pdb | grep -q 'END'
