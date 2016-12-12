import os
import zipfile
import shutil

from utils import download_file

INCHI_URL = 'http://www.inchi-trust.org/download/104/INCHI-1-API.zip'

inchi_zipfile = download_file(INCHI_URL)

zipfile.ZipFile(inchi_zipfile).extractall('.')

INCHI_SRC_DIR = os.path.join(
    os.environ['SRC_DIR'], 'External', 'INCHI-API', 'src'
    )

shutil.copytree('./INCHI-1-API/INCHI_API/inchi_dll', INCHI_SRC_DIR)

