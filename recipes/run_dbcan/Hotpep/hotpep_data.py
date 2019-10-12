# resolve path to Hotpep data file,
# both when installed as a package, and in development

import os.path
import pkg_resources

def hotpep_data_path(*args):
    return pkg_resources.resource_filename('Hotpep', os.path.join(*args))
