#!/bin/sh
set -eux -o pipefail

./configure && make && make install

echo "#!/bin/bash" > ${PREFIX}/bin/LINKS-make
echo "make -f $(command -v ${PREFIX}/bin/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/bin/LINKS-make) \$@" >> ${PREFIX}/bin/LINKS-make
