#! /bin/bash
PMGA="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $PREFIX/bin ${PMGA}

chmod 755 *.py
cp -r custom_allele_sets/ db/ lib/ pmga-build.py pmga.py ${PMGA}

echo "#!/bin/bash" > $PREFIX/bin/pmga
echo "$PMGA/pmga.py \"\${@:1}\"" >> $PREFIX/bin/pmga
chmod 755 $PREFIX/bin/pmga

echo "#!/bin/bash" > $PREFIX/bin/pmga-build
echo "$PMGA/pmga-build.py \"\${@:1}\"" >> $PREFIX/bin/pmga-build
chmod 755 $PREFIX/bin/pmga-build
