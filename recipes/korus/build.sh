#!/bin/bash
set -eu -o pipefail

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

cp -r model ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
cp korus ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

cp korusDecode.py ${PREFIX}/bin/
cp korusEncode ${PREFIX}/bin/
cp korusEncode_pipeline.smk ${PREFIX}/bin/
cp korusMatrix.py ${PREFIX}/bin/
cp korusAggregateMatrices.py ${PREFIX}/bin/

echo "#!/bin/bash" > ${PREFIX}/bin/korus
echo "exec \"${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/korus\" \"\$@\"" >> ${PREFIX}/bin/korus
chmod +x ${PREFIX}/bin/korus
