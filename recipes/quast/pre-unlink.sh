#!/bin/bash

# Since the package is build with `setup.py install` instead of `install_full`,
# some optional dependencies may have been downloaded by QUAST during its usage.
# To remove those, use QUAST's built-in functions (as far as possible).

python -c '
from quast_libs.search_references_meta import logger, download_blastdb
download_blastdb(only_clean=True)

from quast_libs.ra_utils.misc import download_manta
download_manta(logger, only_clean=True)  # initializes manta_dirpath

from os.path import isdir
from shutil import rmtree
from quast_libs.ra_utils.misc import manta_dirpath
from quast_libs.gage import gage_dirpath
for dirpath in (manta_dirpath, gage_dirpath):
    if isdir(dirpath):
        rmtree(dirpath, ignore_errors=True)
'
