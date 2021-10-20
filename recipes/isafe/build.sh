#!/bin/sh

BINARY_HOME=$PREFIX/bin
PACKAGE_HOME=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

mkdir -p $BINARY_HOME $PACKAGE_HOME

rm -rf example

2to3 -w -n --nofix=import .

mv src/isafe.py src/isafe.py.tmp
echo '#!/usr/bin/env python3' > src/isafe.py
echo '' >> src/isafe.py
cat src/isafe.py.tmp >> src/isafe.py
rm src/isafe.py.tmp
chmod u+x src/isafe.py
#SHEBANG='#!/usr/bin/env python3'
#echo -e "${SHEBANG}\n\n$(cat src/isafe.py)" > src/isafe.py

cp -r * $PACKAGE_HOME

chmod u+x ${PACKAGE_HOME}/src/isafe.py
ln -s ${PACKAGE_HOME}/src/isafe.py ${BINARY_HOME}/isafe.py

# isafe_script=${BINARY_HOME}/isafe
# echo '#!/bin/bash' > ${isafe_script}
# echo '' >> ${isafe_script}
# echo 'set -eu -o pipefail' >> ${isafe_script}
# echo '' >> ${isafe_script}
# echo "python ${PACKAGE_HOME}/src/isafe.py \"\$@\"" >> ${isafe_script}
# chmod u+x ${isafe_script}
