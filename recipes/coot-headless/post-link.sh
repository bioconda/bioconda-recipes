#!/bin/bash

set -euo pipefail

GITHUB_RELEASE_URL="https://github.com/pemsley/coot/archive/refs/tags/Release-${PKG_VERSION}.tar.gz"
TEMP_DIR=$(mktemp -d)

COOT_REFMAC_LIB_DIR="${PREFIX}/share/coot/lib"
COOT_DATA_DIR="${COOT_REFMAC_LIB_DIR}/data"
COOT_STANDARD_RESIDUES="${PREFIX}/share/coot/standard-residues.pdb"
COOT_STANDARD_RESIDUES_URL="https://github.com/pemsley/coot/raw/Release-${PKG_VERSION}/standard-residues.pdb"

mkdir -p "${COOT_DATA_DIR}"

echo "Downloading standard-residues.pdb for Coot..."
curl -s -L -o "${COOT_STANDARD_RESIDUES}" "${COOT_STANDARD_RESIDUES_URL}"

if [[ -f "${COOT_STANDARD_RESIDUES}" ]]; then
    chmod 644 "${COOT_STANDARD_RESIDUES}"
    echo "standard-residues.pdb successfully installed to ${COOT_STANDARD_RESIDUES}."
else
    echo "Error: Failed to download standard-residues.pdb" >&2
    exit 1
fi

echo "Downloading monomer library data for Coot from GitHub Release-${PKG_VERSION}..."
if ! command -v curl > /dev/null; then
    echo "Error: curl is not available but it should be. Please check your installation." >&2
    exit 1
fi

curl -s -L "${GITHUB_RELEASE_URL}" | tar -xz -C "${TEMP_DIR}"

RELEASE_DIR="${TEMP_DIR}/coot-Release-${PKG_VERSION}"

if [ -d "${RELEASE_DIR}/monomers" ]; then
    rm -rf "${COOT_DATA_DIR}/monomers"

    cp -R "${RELEASE_DIR}/monomers" "${COOT_DATA_DIR}/"

    find "${COOT_DATA_DIR}/monomers" -type d -exec chmod 755 {} \;
    find "${COOT_DATA_DIR}/monomers" -type f -exec chmod 644 {} \;

    if [ -f "${RELEASE_DIR}/monomers/list/mon_lib_list.cif" ]; then
        mkdir -p "${COOT_DATA_DIR}/monomers/list"
        cp -f "${RELEASE_DIR}/monomers/list/mon_lib_list.cif" "${COOT_DATA_DIR}/monomers/list/"
        echo "mon_lib_list.cif file found and copied."
    else
        echo "Warning: mon_lib_list.cif not found in the downloaded archive. Checking directory structure..."
        find "${RELEASE_DIR}" -name "mon_lib_list.cif" -print
    fi

    rm -rf "${TEMP_DIR}"
    echo "Monomer library successfully installed to ${COOT_DATA_DIR}/monomers"
else
    echo "Error: Monomer directory not found in the downloaded archive" >&2
    rm -rf "${TEMP_DIR}"
    exit 1
fi

find "${COOT_DATA_DIR}/monomers" -name "*Makefile*" -delete
