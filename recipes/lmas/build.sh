#!/bin/bash
LMAS_VERSION="${PKG_VERSION%.*}.x"
LMAS="${PREFIX}/share/${PKG_NAME}-${LMAS_VERSION}"
mkdir -p ${PREFIX}/bin ${LMAS}

chmod 775 LMAS get_data.sh
sed -i 's=main.nf=${LMAS}/main.nf=' LMAS
cp LMAS ${PREFIX}/bin
cp get_sata.sh ${PREFIX}/bin/get_lmas_data.sh

# Move LMAS nextflow
mv conf/ docker/ docs/ lib/ modules/ resources/ templates/ test/ main.nf nextflow.config ${LMAS}
