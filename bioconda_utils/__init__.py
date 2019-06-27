"""
Bioconda Utilities Package

.. rubric:: Subpackages

.. autosummary::
   :toctree:

   bioconda_utils.bot
   bioconda_utils.lint

.. rubric:: Submodules

.. autosummary::
   :toctree:

   aiopipe
   bioconductor_skeleton
   build
   circleci
   cli
   cran_skeleton
   docker_utils
   githandler
   githubhandler
   gitter
   graph
   hosters
   pkg_test
   recipe
   sphinxext
   autobump
   update_pinnings
   upload
   utils
"""

from ._version import get_versions
__version__ = get_versions()["version"]
del get_versions
