import os
import tarfile
import shutil

from utils import download_file

AVALON_URL = (
    'http://downloads.sourceforge.net/project/avalontoolkit/AvalonToolkit_1.2/AvalonToolkit_1.2.0.source.tar'
    )



avalon_tarball = download_file(AVALON_URL)

AVALON_SRC_DIR = os.path.join(
    os.environ['SRC_DIR'], 'External', 'AvalonTools', 'src'
    )

os.makedirs(AVALON_SRC_DIR)

tarfile.open(avalon_tarball).extractall(AVALON_SRC_DIR)

# overwrite the reaccsio.c module with the patched one
RECIPE_DIR = os.path.dirname(__file__)
REACCSIO_SRC = os.path.join(RECIPE_DIR, 'avalon_reaccsio.c')
REACCSIO_DST = os.path.join(
    AVALON_SRC_DIR, 'SourceDistribution', 'common', 'reaccsio.c'
)
shutil.copyfile(REACCSIO_SRC, REACCSIO_DST)
