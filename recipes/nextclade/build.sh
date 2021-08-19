#!/usr/bin/env bash

chmod +x "${SRC_DIR}"/nextclade*
mkdir -p "${PREFIX}/bin"
mv "${SRC_DIR}"/nextclade* "${PREFIX}"/bin/nextclade

NEXTCLADE_VERSION=$PKG_VERSION
NEXTCLADE_INPUTS_URL_BASE="https://raw.githubusercontent.com/nextstrain/nextclade/${NEXTCLADE_VERSION}/data/sars-cov-2"
NEXTCLADE_INPUTS_DIR="${PREFIX}/share/nextclade"
mkdir -p "${NEXTCLADE_INPUTS_DIR}"
pushd "${NEXTCLADE_INPUTS_DIR}" >/dev/null
  curl -fsSLOJ --write-out "[ INFO] curl: %{url_effective}\n" "${NEXTCLADE_INPUTS_URL_BASE}/reference.fasta"
  curl -fsSLOJ --write-out "[ INFO] curl: %{url_effective}\n" "${NEXTCLADE_INPUTS_URL_BASE}/genemap.gff"
  curl -fsSLOJ --write-out "[ INFO] curl: %{url_effective}\n" "${NEXTCLADE_INPUTS_URL_BASE}/tree.json"
  curl -fsSLOJ --write-out "[ INFO] curl: %{url_effective}\n" "${NEXTCLADE_INPUTS_URL_BASE}/qc.json"
  curl -fsSLOJ --write-out "[ INFO] curl: %{url_effective}\n" "${NEXTCLADE_INPUTS_URL_BASE}/primers.csv"
popd >/dev/null