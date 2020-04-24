#!/bin/bash

# Since the package is build with `setup.py install` instead of `install_full`,
# some optional dependencies may have been downloaded by QUAST during its usage.
# To remove those, use QUAST's built-in functions (as far as possible).

python -c '
from os.path import isdir
from shutil import rmtree
from quast_libs import qconfig
from quast_libs.log import get_logger
from quast_libs.ra_utils.misc import download_gridss
from quast_libs.search_references_meta import download_blastdb
from quast_libs.run_busco import download_all_db, download_augustus

logger = get_logger(qconfig.LOGGER_DEFAULT_NAME)
logger.set_up_console_handler()

download_blastdb(logger, only_clean=True)
download_all_db(logger, only_clean=False)
download_augustus(logger, only_clean=True)
download_gridss(logger, only_clean=True)

from quast_libs.ra_utils.misc import gridss_dirpath
if isdir(gridss_dirpath):
    rmtree(gridss_dirpath, ignore_errors=True)
' >> "$PREFIX/.messages.txt" 2>&1
