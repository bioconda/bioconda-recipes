ost compare-structures \
    -m examples/scoring/model.pdb \
    -r examples/scoring/reference.cif.gz \
    --lddt --local-lddt --qs-score

cat out.json | grep -q 'VYTF--STLKSLEEKDHIHRV'
