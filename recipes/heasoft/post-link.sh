#!/usr/bin/env bash

cat <<EOF >> ${PREFIX}/.messages.txt

    After installation, users should initialize the HEAsoft environment with:

    ```
    export HEADAS=$(ls -d "${CONDA_PREFIX}/x86_64-pc-linux-gnu-libc"*/ | head -n 1)
    source ${HEADAS}/headas-init.sh
    export LHEAPERL=${CONDA_PREFIX}/bin/perl
    ```

    This setup configures numerous environment variables required for HEAsoft, including:
    PATH, LD_LIBRARY_PATH, PFILES, PERL5LIB, PYTHONPATH, and various component-specific
    variables like PGPLOT_DIR, XANADU, and POW_LIBRARY.

    Note that LHEAPERL needs to be manually set to point to your Conda environment's
    Perl interpreter after sourcing headas-init.sh.

    For mission-specific functionality (e.g., Swift, NuSTAR, IXPE), additional
    environment setup may be needed. See the HEAsoft documentation for details.

    **Warning for Xspec users**: The /spectral/modelData directory (~5.9GB uncompressed) is excluded to reduce
    package size, rendering Xspec unusable without it.

    To enable Xspec:
    1. Download the HEASoft source tarball for the same version as this package ({{ version }}):
       ```bash
       wget https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft{{ version }}/heasoft-{{ version }}src.tar.gz
       ```
       Replace {{ version }} with the package version (e.g., 6.35.1).
    2. Extract:
       ```bash
       tar zxf heasoft-{{ version }}src.tar.gz
       ```
    3. Copy the modelData directory:
       ```bash
       mkdir -p $CONDA_PREFIX/spectral
       cp -r heasoft-{{ version }}/Xspec/src/spectral/modelData $CONDA_PREFIX/spectral/
       ```
EOF
