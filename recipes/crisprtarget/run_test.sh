#!/bin/bash
set -euo pipefail

# Without arguments CRISPRTarget.pl must report that no BLAST database was
# given (it dies with exit code 2, hence the `|| true`).
out=$(CRISPRTarget.pl 2>&1 || true)
grep -q "BLASTDB" <<< "${out}"

# All scripts must be syntactically valid once patched.
for script in CRISPRTarget.pl \
              CRISPRTargetGraphics.pl \
              CRISPRTarget_cmd.pl \
              CTFlankExtract.pl \
              CTGFFInput.pl \
              CTProcessInput.pl \
              PAMRescore.pl \
              TargetPredict.pl; do
    perl -c "${PREFIX}/bin/${script}"
done

# The tools that upstream vendors in bin/ must come from the dependencies.
for tool in blastn blastdbcmd makeblastdb bedtools samtools esl-shuffle realpath; do
    command -v "${tool}"
done

# No leftover calls to the (removed) bundled binaries.
for script in CRISPRTarget.pl \
              CRISPRTargetGraphics.pl \
              CRISPRTarget_cmd.pl \
              CTFlankExtract.pl \
              CTGFFInput.pl \
              CTProcessInput.pl \
              PAMRescore.pl \
              TargetPredict.pl \
              MakeUserDB.sh \
              MakeUserShuffledDB.sh; do
    ! grep -q 'bin/\(blastn\|blastdbcmd\|makeblastdb\|bedtools\|samtools\|esl-shuffle\)' "${PREFIX}/bin/${script}"
done

# The DB helper scripts must find makeblastdb/samtools/esl-shuffle in PATH.
workdir=$(mktemp -d)
trap 'rm -rf "${workdir}"' EXIT
cd "${workdir}"

printf '>seq1\nACGTACGTACGTACGTACGTACGT\n>seq2\nTTTTGGGGCCCCAAAATTTTGGGG\n' > toy.fna

check_db() {
    local db="$1"
    for ext in nin nhr nsq fai; do
        if [ ! -s "${db}.${ext}" ]; then
            echo "ERROR: ${db}.${ext} was not created" >&2
            ls -l "$(dirname "${db}")" >&2
            exit 1
        fi
    done
}

MakeUserDB.sh toy.fna toy_db > /dev/null
check_db toy_db/toy.fna

MakeUserShuffledDB.sh toy.fna toy_shuffled_db > /dev/null
check_db toy_shuffled_db/toy.fna
