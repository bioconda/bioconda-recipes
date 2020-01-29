#!/bin/bash
set -eu -o pipefail

cd src
make
cd ..

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/ntJoin_exec/bin
mkdir -p ${PREFIX}/ntJoin_exec/src

cp ntJoin ${PREFIX}/ntJoin_exec
cp src/indexlr ${PREFIX}/ntJoin_exec/src/indexlr
cp bin/*py ${PREFIX}/ntJoin_exec/bin

echo "#!/bin/bash" > ${PREFIX}/bin/ntJoin
echo "make -f $(command -v ${PREFIX}/ntJoin_exec/ntJoin) \$@" >> ${PREFIX}/bin/ntJoin
