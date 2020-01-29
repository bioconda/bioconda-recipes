#!/bin/bash
set -eu -o pipefail

cd src
make
cd ..

mkdir -p ${PREFIX}/bin/ntJoin_exec
mkdir -p ${PREFIX}/bin/ntJoin_exec/bin
mkdir -p ${PREFIX}/bin/ntJoin_exec/src

cp ntJoin ${PREFIX}/bin/ntJoin_exec
cp src/indexlr ${PREFIX}/bin/ntJoin_exec/src/indexlr
cp bin/*py ${PREFIX}/bin/ntJoin_exec/bin

echo "#!/bin/bash" > ${PREFIX}/bin/ntJoin
echo "${PREFIX}/bin/ntJoin_exec/ntJoin \$@" >> ${PREFIX}/bin/ntJoin
