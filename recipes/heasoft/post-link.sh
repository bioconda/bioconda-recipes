#!/usr/bin/env bash

cat <<EOF >> ${PREFIX}/.messages.txt

    HEAsoft is a unified release of the FTOOLS and XANADU software packages for high-energy astrophysics data analysis, including tools like XSPEC.

    After installation, users must **initialize the HEAsoft environment** by running the following commands:

    ```
    export HEADAS=$(ls -d "${CONDA_PREFIX}/x86_64-pc-linux-gnu-libc"*/ | head -n 1)
    source "${HEADAS}/headas-init.sh"
    export LHEAPERL="${CONDA_PREFIX}/bin/perl"
    ```

    This setup configures several environment variables required for HEAsoft, including `PATH`, `LD_LIBRARY_PATH`, `PFILES`, `PERL5LIB`, `PYTHONPATH`, and component-specific variables such as `PGPLOT_DIR`, `XANADU`, and `POW_LIBRARY`.

    **Note**: `LHEAPERL` must be manually set to point to your Conda environment's Perl interpreter after sourcing `headas-init.sh`.

    For mission-specific functionality (e.g., Swift, NuSTAR, IXPE), additional environment setup may be required. Refer to the HEAsoft documentation for details.

    **Warning for XSPEC Users**: The `/spectral/modelData` directory (~5.9GB) is excluded from this package to reduce its size, making XSPEC unusable without it. 

    To enable XSPEC, follow these steps:

    1. Download the HEAsoft source tarball for the same version as this package ({{ version }}):
       ```
       wget https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft{{ version }}/heasoft-{{ version }}src.tar.gz
       ```
       Replace `{{ version }}` by the actual the package version (e.g., 6.35.1).

    2. Extract the tarball:
       ```
       tar zxf heasoft-{{ version }}src.tar.gz
       ```

    3. Copy the `modelData` directory to the appropriate location:
       ```
       mkdir -p "${CONDA_PREFIX}/spectral"
       cp -r heasoft-{{ version }}/Xspec/src/spectral/modelData "${CONDA_PREFIX}/spectral/"
       ```

EOF
