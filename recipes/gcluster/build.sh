#!/bin/bash
set -x -e

RM_DIR=${PREFIX}/share/Gcluster

mkdir -p ${PREFIX}/bin
mkdir -p ${RM_DIR}
cp -r * ${RM_DIR}

MCL_DIR="${PREFIX}/bin/mcl"
BLASTP_DIR="${PREFIX}/bin/blastp"
MAKEBLASTDB_DIR="${PREFIX}/bin/makeblastdb"
#export MCL_DIR BLASTP_DIR MAKEBLASTDB_DIR

#original path for mcl, blastp and makrblastdb
MCL_P="/usr/bin/mcl"
BLASTP_P="/usr/bin/blastp"
MAKEBLASTDB_P="/usr/bin/makeblastdb"

#revise the absolute path for three programs within "Gcluster/Gcluster.pl"
sed -i -e "s~${MCL_P}~${MCL_DIR}~g" ${RM_DIR}/Gcluster.pl
sed -i -e "s~${BLASTP_P}~${BLASTP_DIR}~g" ${RM_DIR}/Gcluster.pl
sed -i -e "s~$MAKEBLASTDB_P~${MAKEBLASTDB_DIR}~g" ${RM_DIR}/Gcluster.pl

#revise the absolute path for three programs within "Gcluster/interested_gene_generation.pl"
sed -i -e "s~${BLASTP_P}~${BLASTP_DIR}~g" ${RM_DIR}/interested_gene_generation.pl
sed -i -e "s~$MAKEBLASTDB_P~${MAKEBLASTDB_DIR}~g" ${RM_DIR}/interested_gene_generation.pl

#Copy test data for test
# cp -r ${RM_DIR}/test_data ${RECIPE_DIR}/test_data

# Set a executable file for Gcluster.pl
cat <<END >>${PREFIX}/bin/Gcluster.pl
#!/bin/bash
perl ${RM_DIR}/Gcluster.pl \$@
END

# Set a executable file for interested_gene_generation.pl
cat <<END >>${PREFIX}/bin/interested_gene_generation.pl
#!/bin/bash
perl ${RM_DIR}/interested_gene_generation.pl \$@
END

# Set a executable file for test.pl
cat <<END >>${PREFIX}/bin/test.pl
#!/bin/bash
perl ${RM_DIR}/test.pl
END

chmod a+x ${PREFIX}/bin/Gcluster.pl
chmod a+x ${PREFIX}/bin/interested_gene_generation.pl
chmod a+x ${PREFIX}/bin/test.pl
