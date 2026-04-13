#!/bin/bash
set -x -e

RM_DIR=${PREFIX}/share/gcluster
mkdir -p ${RM_DIR}
mkdir -p ${PREFIX}/bin

ls -a
# 关键修改：仅复制gcluster-v2.0.7目录下的内容到目标路径
cp -r $SRC_DIR/gcluster-v2.0.7/* ${RM_DIR}/

# 复制其他必要的构建文件（如果这些文件在顶层目录）
cp $SRC_DIR/build_env_setup.sh ${RM_DIR}
cp $SRC_DIR/conda_build.sh ${RM_DIR}
cp $SRC_DIR/metadata_conda_debug.yaml ${RM_DIR}


MCL_DIR="${PREFIX}/bin/mcl"
BLASTP_DIR="${PREFIX}/bin/blastp"
MAKEBLASTDB_DIR="${PREFIX}/bin/makeblastdb"
#export MCL_DIR BLASTP_DIR MAKEBLASTDB_DIR

#original path for mcl, blastp and makrblastdb
MCL_P="/usr/bin/mcl"
BLASTP_P="/usr/bin/blastp"
MAKEBLASTDB_P="/usr/bin/makeblastdb"

#revise the absolute path for three programs within "Gcluster/Gcluster.pl"
sed -i -e "s~${MCL_P}~${MCL_DIR}~g" ${RM_DIR}/gcluster.pl
sed -i -e "s~${BLASTP_P}~${BLASTP_DIR}~g" ${RM_DIR}/gcluster.pl
sed -i -e "s~$MAKEBLASTDB_P~${MAKEBLASTDB_DIR}~g" ${RM_DIR}/gcluster.pl

#revise the absolute path for three programs within "Gcluster/interested_gene_generation.pl"
sed -i -e "s~${BLASTP_P}~${BLASTP_DIR}~g" ${RM_DIR}/interested_gene_generation.pl
sed -i -e "s~$MAKEBLASTDB_P~${MAKEBLASTDB_DIR}~g" ${RM_DIR}/interested_gene_generation.pl

#Copy test data for test
# cp -r ${RM_DIR}/test_data ${RECIPE_DIR}/test_data

# Set a executable file for Gcluster.pl
cat <<END >>${PREFIX}/bin/gcluster
#!/bin/bash
perl ${RM_DIR}/gcluster.pl \$@
END


# Set a executable file for interested_gene_generation.pl
cat <<END >>${PREFIX}/bin/interested_gene_generation
#!/bin/bash
perl ${RM_DIR}/interested_gene_generation.pl \$@
END

chmod a+x ${PREFIX}/bin/gcluster
chmod a+x ${PREFIX}/bin/interested_gene_generation
