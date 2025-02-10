import os
from shutil import copyfile
import yaml

from utils.os_utils import expandpath

this_dirname = os.path.dirname(os.path.realpath(__file__))
config_fn = os.path.join(this_dirname, 'config.yaml')
root_dir = os.path.join(this_dirname, os.path.pardir, os.path.pardir)


def get_config():
    with open(config_fn) as f:
        config = yaml.safe_load(f)
    for binary, fn in config['binaries'].items():
        fn = os.path.join(root_dir, fn)
        fn = expandpath(fn)
        config['binaries'][binary] = fn
    return config


def copy_config(outdir):
    copyfile(config_fn, os.path.join(outdir, 'config.yaml'))


config = get_config()
