import os
import subprocess as sp
import logging
from . import utils
logger = logging.getLogger(__name__)


def anaconda_upload(package, token=None, label=None):
    """
    Upload a package to anaconda.

    Parameters
    ----------
    package : str
        Filename to built package

    token : str
        If None, use the environment variable ANACONDA_TOKEN, otherwise, use
        this as the token for authenticating the anaconda client.

    label : str
        Optional label to add, see
        https://docs.continuum.io/anaconda-cloud/using#Uploading. Mostly useful
        for testing.
    """
    label_arg = []
    if label is not None:
        label_arg = ['--label', label]

    if not os.path.exists(package):
        logger.error("UPLOAD ERROR: package %s cannot be found.",
                     package)
        return False

    if token is None:
        token = os.environ.get('ANACONDA_TOKEN')
        if token is None:
            raise ValueError("Env var ANACONDA_TOKEN not found")

    logger.info("UPLOAD uploading package %s", package)
    try:
        cmds = ["anaconda", "-t", token, 'upload', package] + label_arg
        p = utils.run(cmds, mask=[token])
        logger.info("UPLOAD SUCCESS: uploaded package %s", package)
        return True

    except sp.CalledProcessError as e:
        if "already exists" in e.stdout:
            # ignore error assuming that it is caused by
            # existing package
            logger.warning(
                "UPLOAD WARNING: tried to upload package, got: "
                "%s", e.stdout)
            return True
        else:
            logger.error('UPLOAD ERROR: command: %s', e.cmd)
            logger.error('UPLOAD ERROR: stdout+stderr: %s', e.stdout)
            raise e


def mulled_upload(image, quay_target):
    """
    Upload the build Docker images to quay.io with 'mulled-build push'
    """
    cmd = ['mulled-build', 'push', image, '-n', quay_target]
    mask = []
    if os.environ.get('QUAY_OAUTH_TOKEN', False):
        token = os.environ['QUAY_OAUTH_TOKEN']
        cmd.extend(['--oauth-token', token])
        mask = [token]
    return utils.run(cmd, mask=mask)
