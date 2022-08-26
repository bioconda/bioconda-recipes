#!/bin/sh
set -eux -o pipefail

 ./configure --prefix=${PREFIX}
make
make install

mv ${PREFIX}/bin/LINKS-make ${PREFIX}/bin/LINKS-make-real
echo "#!/bin/bash" > ${PREFIX}/bin/LINKS-make
echo "make -f $(command -v ${PREFIX}/bin/LINKS-make-real) \$@" >> ${PREFIX}/bin/LINKS-make