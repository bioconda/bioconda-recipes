#!/usr/bin/env bash

UPDIO_DIR=${PREFIX}/share/updio
mkdir -p ${UPDIO_DIR} ${UPDIO_DIR}/sample_data ${UPDIO_DIR}/scripts

cp ${SRC_DIR}/scripts/plot_zygosity_and_events.R ${UPDIO_DIR}/scripts/
cp ${SRC_DIR}/sample_data/common_dels_1percent.tsv ${UPDIO_DIR}/sample_data/common_dels_1percent.tsv
cp ${SRC_DIR}/UPDio.pl ${UPDIO_DIR}/UPDio.pl
chmod 0755 ${UPDIO_DIR}/UPDio.pl

ln -rs ${UPDIO_DIR}/UPDio.pl ${PREFIX}/bin/updio
