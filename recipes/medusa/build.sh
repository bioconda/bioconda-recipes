#!/bin/bash
set -eu -o pipefail

OUTPREFIX=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}

# Create directory
mkdir -p ${OUTPREFIX}
mkdir -p ${OUTPREFIX}/script

# Copy bin file and script
cp medusa.jar ${OUTPREFIX}
cp medusa_scripts/* ${OUTPREFIX}/script/

mkdir -p ${PREFIX}/bin
cat > ${PREFIX}/bin/medusa <<EOF
#!/bin/bash

java -jar ${OUTPREFIX}/medusa.jar -scriptPath ${OUTPREFIX}/script/ \$@

EOF

chmod +x ${PREFIX}/bin/medusa
