# the osx version has to be built from source
PLATFORM=$(uname)
SRCDIR="doc"
if [ ${PLATFORM} == "Darwin" ]; then
    ./make/makedis.csh
    SRCDIR="doc/blast"
fi

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

# relevant documetation
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

# copy executables
mkdir "${PREFIX}"/bin
for EXE in "${EXES[@]}"; do
    cp bin/"${EXE}" "${PREFIX}"/bin/"${EXE}"
done

# copy data files
mkdir "${PREFIX}"/data
for DATA_FILE in "${DATA_FILES[@]}"; do
    cp data/"${DATA_FILE}" "${PREFIX}"/data/"${DATA_FILE}"
done

# copy documentation
mkdir "${PREFIX}"/doc
for DOC_FILE in "${DOC_FILES[@]}"; do
    cp "${SRCDIR}"/"${DOC_FILE}" "${PREFIX}"/doc/"${DOC_FILE}"
done
