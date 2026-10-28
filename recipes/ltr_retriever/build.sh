#!/bin/sh
set -x -e

LTRR_DIR=${PREFIX}/share/LTR_retriever

mkdir -p ${PREFIX}/bin
mkdir -p ${LTRR_DIR}
cp -r * ${LTRR_DIR}

# -----------------
# Deal with main scripts "LTR_retriever LAI"
cat <<END >>${PREFIX}/bin/LTR_retriever
#!/bin/bash
NAME=\$(basename \$0)
perl ${LTRR_DIR}/\${NAME} \$@
END

chmod a+x ${PREFIX}/bin/LTR_retriever
ln -s ${PREFIX}/bin/LTR_retriever ${PREFIX}/bin/LAI

# -----------------
# Deal with bin scripts "convert_ltr_struc.pl convert_MGEScan3.0.pl convert_ltrdetector.pl"
cat <<END >>${PREFIX}/bin/convert_ltr_struc.pl
#!/bin/bash
NAME=\$(basename \$0)
perl ${LTRR_DIR}/bin/\${NAME} \$@
END

chmod a+x ${PREFIX}/bin/convert_ltr_struc.pl
ln -s ${PREFIX}/bin/convert_ltr_struc.pl ${PREFIX}/bin/convert_MGEScan3.0.pl
ln -s ${PREFIX}/bin/convert_ltr_struc.pl ${PREFIX}/bin/convert_ltrdetector.pl
