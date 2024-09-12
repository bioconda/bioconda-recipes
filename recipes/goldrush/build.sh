#!/bin/bash
set -eu -o pipefail

# Build goldrush
mkdir -p ${PREFIX}/bin
meson --prefix ${PREFIX} build
cd build
ninja
ninja install

# Make wrapper script for goldrush
mv ${PREFIX}/bin/goldrush ${PREFIX}/bin/goldrush.make
echo "#!/bin/bash" > ${PREFIX}/bin/goldrush
echo "make -rRf $(which goldrush.make) \$@" >> ${PREFIX}/bin/goldrush
chmod 755 ${PREFIX}/bin/goldrush*
