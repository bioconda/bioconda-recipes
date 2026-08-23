#!/usr/bin/env bash
set -euo pipefail

version_output="$(seqproc --version --verbose)"
printf '%s\n' "${version_output}"
printf '%s\n' "${version_output}" | grep -F "seqproc 0.1.1"

# Bioconda artifacts must never inherit the build worker's native ISA. The
# backend name is stable public provenance supplied by ANTISEQUENCE.
if printf '%s\n' "${version_output}" | grep -F "compiler CPU target: native"; then
  echo "Bioconda package was compiled for the build host's native CPU" >&2
  exit 1
fi
case "$(uname -m)" in
  x86_64) printf '%s\n' "${version_output}" | grep -F "SIMD backend: x86-sse2" ;;
  arm64|aarch64) printf '%s\n' "${version_output}" | grep -F "SIMD backend: arm-neon" ;;
  *) echo "unsupported test architecture: $(uname -m)" >&2; exit 1 ;;
esac

test_dir="$(mktemp -d)"
trap 'rm -rf "${test_dir}"' EXIT
printf '1{r:}\n' > "${test_dir}/passthrough.efgdl"
printf '@read1\nACGTACGT\n+\nIIIIIIII\n' > "${test_dir}/input.fastq"

seqproc validate "${test_dir}/passthrough.efgdl"
seqproc run --geom "${test_dir}/passthrough.efgdl" \
  --read1 "${test_dir}/input.fastq" --out1 "${test_dir}/output.fastq" \
  --threads 1
cmp "${test_dir}/input.fastq" "${test_dir}/output.fastq"

seqproc run --geom "${test_dir}/passthrough.efgdl" \
  --read1 "${test_dir}/input.fastq" --out1 - --threads 1 \
  | cmp "${test_dir}/input.fastq" -
