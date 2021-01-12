TPSI_DIR=${PREFIX}/share/transposonPSI
TPSI_PROGRAMS="BPbtab TBLASTN_hit_chainer.pl TBLASTN_hit_chainer_nonoverlapping_genome_DP_extraction.pl TPSI_btab_to_gff3.pl TPSI_chains_to_fasta.pl TPSI_chains_to_gff3.pl m2fmt_tier_hits.pl transposon_db_m2fmt_to_gff3.pl"

# Copy the installed package to the right location
mkdir -p ${PREFIX}/bin
mkdir -p ${TPSI_DIR}
cp -r *  ${TPSI_DIR}


cat <<END >>${PREFIX}/bin/transposonPSI.pl
#!/bin/bash

NAME=\$(basename \$0)
${TPSI_DIR}/\${NAME}
END

# copy tools in the bin
chmod a+x ${PREFIX}/bin/transposonPSI.pl

 for PROGRAM in ${TPSI_PROGRAMS} ; do
 	ln -s ${PREFIX}/bin/transposonPSI.pl ${PREFIX}/bin/$(basename $PROGRAM)
 done
