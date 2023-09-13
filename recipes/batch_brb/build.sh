#!/bin/bash
set -euxo pipefail


mkdir -p ${PREFIX}/{bin,etc}

#Setup scripts
cp -v ${SRC_DIR}/scripts/batch_brb_setup ${PREFIX}/bin/batch_brb_setup
cp -v ${SRC_DIR}/scripts/show ${PREFIX}/bin/show

#batch_makeblastdb pipeline
cp -v ${SRC_DIR}/scripts/batch_makeblastdb ${PREFIX}/bin/batch_makeblastdb
cp -v ${SRC_DIR}/scripts/mdb01_makeblastdb.sh ${PREFIX}/bin/mdb01_makeblastdb.sh
cp -v ${SRC_DIR}/scripts/mdb02_convert_headers.py ${PREFIX}/bin/mdb02_convert_headers.py
cp -v ${SRC_DIR}/scripts/mdb03_add_to_db.py ${PREFIX}/bin/mdb03_add_to_db.py

#aliasdb_pipeline
cp -v ${SRC_DIR}/scripts/aliasdb_pipeline ${PREFIX}/bin/aliasdb_pipeline
cp -v ${SRC_DIR}/scripts/adb01_check_db.py ${PREFIX}/bin/adb01_check_db.py
cp -v ${SRC_DIR}/scripts/adb02_add_alias_to_db.py ${PREFIX}/bin/adb02_add_alias_to_db.py

#accession_retrieve pipeline
cp -v ${SRC_DIR}/scripts/accession_retrieve ${PREFIX}/bin/accession_retrieve
cp -v ${SRC_DIR}/scripts/ar01_accret.py ${PREFIX}/bin/ar01_accret.py

#orthology pipeline
cp -v ${SRC_DIR}/scripts/orthology_pipeline ${PREFIX}/bin/orthology_pipeline
cp -v ${SRC_DIR}/scripts/or01_filter_hits.py ${PREFIX}/bin/or01_filter_hits.py
cp -v ${SRC_DIR}/scripts/or02_find_orthologs.py ${PREFIX}/bin/or02_find_orthologs.py
cp -v ${SRC_DIR}/scripts/batch_brb_functions.py ${PREFIX}/bin/batch_brb_functions.py

#merge results
cp -v ${SRC_DIR}/scripts/merge_results ${PREFIX}/bin/merge_results

#FastTree pipeline
cp -v ${SRC_DIR}/scripts/fasttree_pipeline ${PREFIX}/bin/fasttree_pipeline
cp -v ${SRC_DIR}/scripts/ft01_extract_accessions.py ${PREFIX}/bin/ft01_extract_accessions.py

#delete_db pipeline
cp -v ${SRC_DIR}/scripts/delete_db ${PREFIX}/bin/delete_db
cp -v ${SRC_DIR}/scripts/del01_delete_db_entries.py ${PREFIX}/bin/del01_delete_db_entries.py

#templates and documentation folders
#mkdir -p ${PREFIX}/etc/{templates/{CSVs,Excel_files},documentation}
cp ${SRC_DIR}/templates/CSVs/* ${PREFIX}/etc/
cp ${SRC_DIR}/templates/Excel_files/* ${PREFIX}/etc/
cp ${SRC_DIR}/documentation/* ${PREFIX}/etc/





ls -l $PREFIX/bin
ls -l $PREFIX/etc






