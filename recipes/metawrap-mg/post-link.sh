#!/bin/sh

CHECKM_DIR="${PREFIX}/etc/checkm"
CHECKM_URL="https://zenodo.org/record/7401545/files/checkm_data_2015_01_16.tar.gz"

wget -O checkm_data.tar.gz \
	"${CHECKM_URL}"

mkdir -p "${CHECKM_DIR}"

tar -zxf checkm_data.tar.gz \
	-C "${CHECKM_DIR}" \
	--strip-components 1

checkm data setRoot	"${CHECKM_DIR}"
