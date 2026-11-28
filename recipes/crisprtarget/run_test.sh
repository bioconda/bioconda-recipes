#!/bin/bash
set -euo pipefail

perl_scripts="CRISPRTarget.pl
CRISPRTargetGraphics.pl
CRISPRTarget_cmd.pl
CTFlankExtract.pl
CTGFFInput.pl
CTProcessInput.pl
PAMRescore.pl
TargetPredict.pl"

sh_scripts="MakeUserDB.sh
MakeUserShuffledDB.sh"

# Without arguments CRISPRTarget.pl must report that no BLAST database was
# given (it dies with exit code 2, hence the `|| true`).
out=$(CRISPRTarget.pl 2>&1 || true)
grep -q "BLASTDB" <<< "${out}"

# The tools that upstream vendors in bin/ must come from the dependencies.
for tool in blastn blastdbcmd makeblastdb bedtools samtools esl-shuffle realpath; do
    command -v "${tool}"
done

check_script() {
    local script="$1"
    local interpreter="$2"

    if [ ! -x "${PREFIX}/bin/${script}" ]; then
        echo "ERROR: ${PREFIX}/bin/${script} is missing or not executable" >&2
        exit 1
    fi

    IFS= read -r shebang < "${PREFIX}/bin/${script}"
    if [ "${shebang}" != "#!${interpreter}" ]; then
        echo "ERROR: unexpected shebang in ${script}: ${shebang}" >&2
        exit 1
    fi

    # no leftover calls to the (removed) bundled binaries
    if grep -q 'bin/\(blastn\|blastdbcmd\|makeblastdb\|bedtools\|samtools\|esl-shuffle\)' \
            "${PREFIX}/bin/${script}"; then
        echo "ERROR: ${script} still calls the bundled binaries" >&2
        exit 1
    fi
}

for script in ${perl_scripts}; do
    check_script "${script}" "/usr/bin/env perl"
    perl -c "${PREFIX}/bin/${script}"
done

for script in ${sh_scripts}; do
    check_script "${script}" "/usr/bin/env bash"
    bash -n "${PREFIX}/bin/${script}"
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
