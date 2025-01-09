#!/bin/bash
set -x -e

TIR_LEARNER_DIR="${PREFIX}/share/TIR-Learner3"

mkdir -p ${PREFIX}/bin
mkdir -p ${TIR_LEARNER_DIR}
cp -rf TIR-Learner3/* ${TIR_LEARNER_DIR}

cat <<END >>${PREFIX}/bin/TIR-Learner
#!/bin/bash
python3 ${TIR_LEARNER_DIR}/TIR-Learner.py \$@
END

chmod 0755 ${PREFIX}/bin/TIR-Learner
