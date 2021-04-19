"""
Deploy Artifacts to Anaconda and Quay
"""

import os
import subprocess as sp
import logging
from . import utils
logger = logging.getLogger(__name__)


def anaconda_upload(package: str, token: str = None, label: str = None) -> bool:
    """
    Upload a package to anaconda.

    Args:
      package: Filename to built package
      token: If None, use the environment variable ``ANACONDA_TOKEN``,
             otherwise, use this as the token for authenticating the
             anaconda client.
      label: Optional label to add
    Returns:
      True if the operation succeeded, False if it cannot succeed,
      None if it should be retried
    Raises:
      ValueError
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
        utils.run(cmds, mask=[token])
        logger.info("UPLOAD SUCCESS: uploaded package %s", package)
        return True

    except sp.CalledProcessError as e:
        if "already exists" in e.stdout:
            # ignore error assuming that it is caused by
            # existing package
            logger.warning(
                "UPLOAD WARNING: tried to upload package, got:\n "
                "%s", e.stdout)
            return True
        elif "Gateway Timeout" in e.stdout:
            logger.warning("UPLOAD TEMP FAILURE: Gateway timeout")
            return False
        else:
            logger.error('UPLOAD ERROR: command: %s', e.cmd)
            logger.error('UPLOAD ERROR: stdout+stderr: %s', e.stdout)
            return False


def mulled_upload(image: str, quay_target: str) -> sp.CompletedProcess:
    """
    Upload the build Docker images to quay.io with ``mulled-build push``.

    Calls ``mulled-build push <image> -n <quay_target>``

    Args:
      image: name of image to push
      quary_target: name of image on quay
    """
    cmd = ['mulled-build', 'push', image, '-n', quay_target]
    mask = []
    if os.environ.get('QUAY_OAUTH_TOKEN', False):
        token = os.environ['QUAY_OAUTH_TOKEN']
        cmd.extend(['--oauth-token', token])
        mask = [token]
    return utils.run(cmd, mask=mask)


def skopeo_upload(image_file: str, target: str,
                  creds: str, registry: str = "quay.io",
                  timeout: int = 600) -> bool:
    """
    Upload an image to docker registy

    Uses ``skopeo`` to upload tar archives of docker images as created
    with e.g.``docker save`` to a docker registry.

    The image name and tag are read from the archive.

    Args:
      image_file: path to the file to be uploaded (may be gzip'ed)
      target: namespace/repo for the image
      creds: login credentials (``USER:PASS``)
      registry: url of the registry. defaults to "quay.io"
      timeout: timeout in seconds
    """
    cmd = ['skopeo',
           '--insecure-policy', # disable policy checks
           '--command-timeout', str(timeout) + "s",
           'copy',
           'docker-archive:{}'.format(image_file),
           'docker://{}/{}'.format(registry, target),
           '--dest-creds', creds]
    try:
        utils.run(cmd, mask=creds.split(':'))
        return True
    except sp.CalledProcessError as exc:
        logger.error("Failed to upload %s to %s", image_file, target)
        for line in exc.stdout.splitlines():
            logger.error("> %s", line)
        return False
