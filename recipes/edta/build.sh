#!/bin/sh
set -x -e

EDTA_DIR=${PREFIX}/share/EDTA
EDTA_OTHER_PROGRAMS="EDTA_raw.pl EDTA_processI.pl"

mkdir -p ${PREFIX}/bin
mkdir -p ${EDTA_DIR}
cp -r * ${EDTA_DIR}

for name in ${EDTA_PROGRAMS} ; do
  ln -s ${EDTA_DIR}/$name ${PREFIX}/bin/$name
done

cat <<END >>${PREFIX}/bin/EDTA.pl
#!/bin/bash
NAME=\$(basename \$0)
perl ${EDTA_DIR}/\${NAME} \$@
END

chmod a+x ${PREFIX}/bin/EDTA.pl
for name in ${RM_OTHER_PROGRAMS} ; do
  ln -s ${PREFIX}/bin/EDTA.pl ${PREFIX}/bin/$(basename $name)
done
