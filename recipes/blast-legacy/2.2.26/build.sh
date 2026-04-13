#!/bin/bash

mkdir -p "${PREFIX}/bin"

if [[ `uname` == "Linux" ]]; then
    sed -i.bak 's|#!/bin/csh -f|#!/usr/bin/env tcsh|' make/makedis.csh
    sed -i.bak 's|#!/bin/csh -f|#!/usr/bin/env tcsh|' make/ln-if-absent
    rm -rf make/*.bak
fi

export PLATFORM=$(uname)
export SRCDIR="doc/blast"

./make/makedis.csh

# binaires to be copied to env bin
EXES=(
    bl2seq
    blastall
    blastclust
    blastpgp
    copymat
    fastacmd
    formatdb
    formatrpsdb
    impala
    makemat
    megablast
    rpsblast
    seedtop
)

# data files required for full functionality -- to be copied to env
DATA_FILES=(
    BLOSUM45
    BLOSUM62
    BLOSUM80
    KSat.flt
    KSchoth.flt
    KSgc.flt
    KShopp.flt
    KSkyte.flt
    KSpcc.mat
    KSpur.flt
    KSpyr.flt
    PAM30
    PAM70
    UniVec.nhr
    UniVec.nin
    UniVec.nsq
    UniVec_Core.nhr
    UniVec_Core.nin
    UniVec_Core.nsq
    asn2ff.prt
    bstdt.val
    ecnum_ambiguous.txt
    ecnum_specific.txt
    featdef.val
    gc.val
    humrep.fsa
    lineages.txt
    makerpt.prt
    objprt.prt
    organelle_products.prt
    product_rules.prt
    pubkey.enc
    seqcode.val
    sequin.hlp
    sgmlbb.ent
    taxlist.txt
)

# relevant documentation
DOC_FILES=(
    bl2seq.html
    blast.html
    blastall.html
    blastclust.html
    blastdb.html
    blastftp.html
    blastpgp.html
    fastacmd.html
    filter.html
    formatdb.html
    formatrpsdb.html
    history.html
    impala.html
    index.html
    megablast.html
    netblast.html
    rpsblast.html
    scoring.pdf
    web_blast.pl
)

# install executables
for EXE in "${EXES[@]}"; do
    install -v -m 0755 "bin/${EXE}" "${PREFIX}/bin"
done

# copy data files
mkdir -p "${PREFIX}/data"
for DATA_FILE in "${DATA_FILES[@]}"; do
    cp -rf "data/${DATA_FILE}" "${PREFIX}/data/${DATA_FILE}"
done

# copy documentation
mkdir -p "${PREFIX}/doc"
for DOC_FILE in "${DOC_FILES[@]}"; do
    cp -rf "${SRCDIR}/${DOC_FILE}" "${PREFIX}/doc/${DOC_FILE}"
done
