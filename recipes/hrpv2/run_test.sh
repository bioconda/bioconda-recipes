#!/usr/bin/env bash
set -euo pipefail

python -c 'import sys; assert sys.version_info[:2] == (3, 12), sys.version'
java -version 2>&1 | grep -E 'version "11([.]|\")'
hmmbuild -h | grep -F 'HMMER 3.4'
meme -version | grep -Fx '5.5.9'
mafft --version 2>&1 | grep -F 'v7.526'

HRPv2 --version | grep -Fx "HRPv2"
HRPv2 --help >/dev/null
HRPv2 --help | grep -q -- "--interproscan-bin"
if HRPv2 --help | grep -q -- "--rescue-env"; then
  exit 1
fi

python -m py_compile "$(command -v HRPv2)"
bash -n "$(command -v run_genblastG)"

for command_name in \
  run_genblastG genblastG blastall formatdb \
  hmmbuild hmmsearch meme meme2meme mast mafft
do
  command -v "${command_name}" >/dev/null
done

test -r "${PREFIX}/share/hrpv2/alignscore.txt"
test "$(wc -l < "${PREFIX}/share/hrpv2/alignscore.txt")" -eq 281
grep -Fx -- "-o:-11" "${PREFIX}/share/hrpv2/alignscore.txt"
grep -Fx -- "**:1" "${PREFIX}/share/hrpv2/alignscore.txt"

