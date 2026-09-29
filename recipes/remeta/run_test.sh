#!/usr/bin/env bash
set -euo pipefail
set -x

test -x "${PREFIX}/bin/remeta"

remeta --version > /dev/null

expect_usage_exit_1() {
  local expected="$1"
  shift
  local output
  local status

  set +e
  output="$("$@" 2>&1)"
  status=$?
  set -e

  test "${status}" -eq 1
  printf '%s\n' "${output}" | grep -q "${expected}"
}

expect_usage_exit_1 "Usage: remeta" remeta --help

for subcommand in gene esma pvma merge compute-ref-ld index-anno; do
  expect_usage_exit_1 "Usage: remeta ${subcommand}" remeta "${subcommand}"
done

cat > tiny.annotations <<'EOF'
1:100:A:C GENE1 LoF
1:200:G:T GENE1 missense
EOF

bgzip -c tiny.annotations > tiny.annotations.gz
remeta index-anno --file tiny.annotations.gz --stride 1000
test -s tiny.annotations.gz.rgi
