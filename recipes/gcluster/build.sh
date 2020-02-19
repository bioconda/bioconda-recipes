#!/bin/bash
set -x -e

RM_DIR=${PREFIX}/share/gcluster

mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}

MCL_DIR="${PREFIX}/bin/mcl"
BLASTP_DIR="${PREFIX}/bin/blastp"
MAKEBLASTDB_DIR="${PREFIX}/bin/makeblastdb"
#export MCL_DIR BLASTP_DIR MAKEBLASTDB_DIR
MCL_P="/usr/bin/mcl"
BLASTP_P="/usr/bin/blastp"
MAKEBLASTDB_P="/usr/bin/makeblastdb"

sed -i -e "s~${MCL_P}~${MCL_DIR}~g" ${RM_DIR}/gcluster.pl
sed -i -e "s~${BLASTP_P}~${BLASTP_DIR}~g" ${RM_DIR}/gcluster.pl
sed -i -e "s~$MAKEBLASTDB_P~${MAKEBLASTDB_DIR}~g" ${RM_DIR}/gcluster.pl

sed -i -e "s~${BLASTP_P}~${BLASTP_DIR}~g" ${RM_DIR}/interested_gene_generation.pl
sed -i -e "s~$MAKEBLASTDB_P~${MAKEBLASTDB_DIR}~g" ${RM_DIR}/interested_gene_generation.pl





# Copy edited config file for auto configuration
cp -r ${RM_DIR}/test_data ${RECIPE_DIR}/test_data


# Set a executable file for Gcluster.pl
cat <<END >>${PREFIX}/bin/Gcluster
#!/bin/bash
perl ${RM_DIR}/Gcluster.pl \$@
END


# Set a executable file for interested_gene_generation.pl
cat <<END >>${PREFIX}/bin/interested_gene_generation
#!/bin/bash
perl ${RM_DIR}/interested_gene_generation.pl \$@
END



chmod a+x ${PREFIX}/bin/Gcluster
chmod a+x ${PREFIX}/bin/interested_gene_generation