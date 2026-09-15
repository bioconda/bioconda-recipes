#!/bin/bash
set -euo pipefail

VERSION="3.7.4"
URL="http://bioinfo-ai.cn/downloads/Released_Software/parallel-meta/3.7.4/win_linux/parallel-meta-suite-3.7.4-src.tar.gz"
SHA256="ba2c2bb0316d922ba59c0e081e59df80440640424b6e5f8d363e9c6a2695b6fe"

if [ -z "${ParallelMETA:-}" ]; then
    echo "Error: ParallelMETA is not set."
    echo "Please activate the Parallel-META Suite Conda environment first."
    exit 1
fi

echo "Parallel-META Suite ${VERSION} database installer"
echo "ParallelMETA=${ParallelMETA}"

if [ -f "${ParallelMETA}/databases/db.config" ] && \
   [ -d "${ParallelMETA}/models" ] && \
   [ -d "${ParallelMETA}/html" ] && \
   [ -d "${ParallelMETA}/PMS-config" ] && \
   [ -d "${ParallelMETA}/example" ]; then
    echo "Parallel-META Suite runtime resources already exist:"
    echo "${ParallelMETA}"
    echo "Nothing to do."
    exit 0
fi

for cmd in curl tar openssl awk; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: required command not found: $cmd"
        exit 1
    fi
done

TMPDIR_PMS="$(mktemp -d "${TMPDIR:-/tmp}/pms-db.XXXXXX")"
ARCHIVE="${TMPDIR_PMS}/parallel-meta-suite-${VERSION}-src.tar.gz"

cleanup() {
    rm -rf "${TMPDIR_PMS}"
}
trap cleanup EXIT

echo
echo "Downloading PMS ${VERSION} database release..."
MAX_DOWNLOAD_ATTEMPTS=100
attempt=1

while :; do
    echo "Download attempt ${attempt}/${MAX_DOWNLOAD_ATTEMPTS}"

    if curl -fL \
        -C - \
        --retry 3 \
        --retry-all-errors \
        --retry-delay 5 \
        --connect-timeout 20 \
        -o "${ARCHIVE}" \
        "${URL}"; then
        break
    else
        rc=$?
    fi

    if [ -f "${ARCHIVE}" ]; then
        bytes="$(wc -c < "${ARCHIVE}")"
    else
        bytes=0
    fi

    echo "Download interrupted (curl exit ${rc}); partial bytes: ${bytes}"

    if [ "${attempt}" -ge "${MAX_DOWNLOAD_ATTEMPTS}" ]; then
        echo "Error: download failed after ${MAX_DOWNLOAD_ATTEMPTS} attempts."
        exit "${rc}"
    fi

    attempt=$((attempt + 1))
    sleep 5
done

echo
echo "Verifying SHA256..."
ACTUAL_SHA256="$(openssl dgst -sha256 "${ARCHIVE}" | awk '{print $NF}')"

if [ "${ACTUAL_SHA256}" != "${SHA256}" ]; then
    echo "Error: SHA256 verification failed."
    echo "Expected: ${SHA256}"
    echo "Actual:   ${ACTUAL_SHA256}"
    exit 1
fi

echo "SHA256 OK"

echo
echo "Extracting databases..."
mkdir -p "${ParallelMETA}"

tar -xzf "${ARCHIVE}" \
    -C "${ParallelMETA}" \
    --strip-components=1 \
    parallel-meta-suite/databases \
    parallel-meta-suite/models \
    parallel-meta-suite/html \
    parallel-meta-suite/PMS-config \
    parallel-meta-suite/example

echo
echo "Runtime resource installation complete:"
du -sh "${ParallelMETA}/databases"
