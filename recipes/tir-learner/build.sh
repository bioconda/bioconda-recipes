#!/bin/sh
set -x -e

TIR_LEARNER_DIR=${PREFIX}/share/TIR-Learner3.0

mkdir -p ${PREFIX}/bin
mkdir -p ${TIR_LEARNER_DIR}
cp -r TIR-Learner3.0/* ${TIR_LEARNER_DIR}

cat <<END >>${PREFIX}/bin/TIR-Learner
#!/bin/bash
python3 ${TIR_LEARNER_DIR}/TIR-Learner3.0.py \$@
END

chmod a+x ${PREFIX}/bin/TIR-Learner
