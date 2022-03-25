#!/bin/bash
LMAS_VERSION="${PKG_VERSION%.*}.x"
LMAS="${PREFIX}/share/${PKG_NAME}-${LMAS_VERSION}"
mkdir -p ${PREFIX}/bin ${LMAS}

chmod 775 LMAS get_data.sh
cp get_data.sh ${PREFIX}/bin/get_lmas_data.sh

echo "#!/bin/bash" > $PREFIX/bin/LMAS
echo "$LMAS/LMAS \"\${@:1}\"" >> $PREFIX/bin/LMAS
chmod 755 $PREFIX/bin/LMAS

# Move LMAS
mv conf/ docker/ docs/ lib/ modules/ resources/ templates/ test/ main.nf nextflow.config LMAS ${LMAS}
