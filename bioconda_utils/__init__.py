"""
Bioconda Utilities Package

.. rubric:: Subpackages

.. autosummary::
   :toctree:

   bioconda_utils.bot

.. rubric:: Submodules

.. autosummary::
   :toctree:

   cli
   async
   bioconductor_skeleton
   build
   circleci
   cli
   cran_skeleton
   docker_utils
   githandler
   github_integration
   githubhandler
   gitter
   graph
   hosters
   lint_functions
   linting
   pkg_test
   recipe
   sphinxext
   update
   update_pinnings
   upload
   utils
"""

from ._version import get_versions
__version__ = get_versions()["version"]
del get_versions
