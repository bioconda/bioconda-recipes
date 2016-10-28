[![Travis builds](https://img.shields.io/travis/bioconda/bioconda-utils/master.svg?style=flat-square&label=builds)](https://travis-ci.org/bioconda/bioconda-utils)
[![Gitter](https://badges.gitter.im/bioconda/bioconda-recipes.svg)](https://gitter.im/bioconda/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

![](https://raw.githubusercontent.com/bioconda/bioconda-recipes/master/logo/bioconda_monochrome_small.png
 "Bioconda")

Utilities for building and managing
[bioconda](https://github.com/bioconda/bioconda-recipes) recipes.

Installation:

First, note that `bioconda-utils` requires both python3 and `conda-build` pre-installed.
This means that you likely need to have installed conda via the `miniconda3` bundle.

```
pip install git+https://github.com/bioconda/bioconda-utils.git
```

See the help for the `bioconda-utils` command-line interface for details:

```
bioconda-utils -h
```

## Changelog

- recipes can be built in a docker container or by the system conda-build using the same infrastructure
- improved log files for easy grepping (e.g., `grep BIOCONDA log`)
- given a subdag of recipes to build, if one recipe fails then other recipes
  that depend on it will be skipped (and noted in the log).
- uses the API from conda 2.0+ and in general works with the latest conda-build
  versions (instead of maintaining our own branch)
- test suite for the build tools
- documentation
- each built package can now be tested in an isolated busybox container thanks
  to `mulled-build` and `involucro`. This will catch issues where a recipe fails
  to specify libs (e.g., libgcc) in the run dependencies.
- the `mulled-build` testing also means we get per-package docker containers for free


## Developer notes

New version of conda-build? Update `DEFAULT_CONDA_BUILD_VERSION` in
[`docker_utils.py`](bioconda_utils/docker_utils.py) which is the version used
for docker containers, and the version spec in
[`conda-requirements.txt`](conda-requirements.txt) which is used to set up the
system environment and will therefore be used for non-docker builds (primarily
OSX but will also be used for Linux if `--docker` is not provided to
`bioconda-utils build`).

For example see [#24](https://github.com/bioconda/bioconda-utils/pull/24/files).

