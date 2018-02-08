#!/bin/bash

# Since the package is build with `setup.py install` instead of `install_full`,
# some optional dependencies may have been downloaded by QUAST during its usage.
# To remove those, use QUAST's built-in functions (as far as possible).

python -c '
from os.path import isdir
from shutil import rmtree
from quast_libs import qconfig
from quast_libs.log import get_logger
from quast_libs.ra_utils.misc import download_manta
from quast_libs.search_references_meta import download_blastdb

logger = get_logger(qconfig.LOGGER_DEFAULT_NAME)
logger.set_up_console_handler()

download_blastdb(logger, only_clean=True)
download_manta(logger, only_clean=True)  # initializes manta_dirpath

from quast_libs.ra_utils.misc import manta_dirpath
if isdir(manta_dirpath):
    rmtree(manta_dirpath, ignore_errors=True)
' >> "$PREFIX/.messages.txt" 2>&1
