[![CircleCI](https://circleci.com/gh/bioconda/bioconda-utils/tree/master.svg?style=shield)](https://circleci.com/gh/bioconda/bioconda-utils/tree/master)
[![Gitter](https://badges.gitter.im/bioconda/bioconda-recipes.svg)](https://gitter.im/bioconda/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

![](https://raw.githubusercontent.com/bioconda/bioconda-recipes/master/logo/bioconda_monochrome_small.png
 "Bioconda")

`bioconda-utils` is a set of utilities for building and managing
[bioconda](https://github.com/bioconda/bioconda-recipes) recipes.

Since `bioconda-utils` is tightly coupled to `bioconda-recipes`, it is
strongly recommended that `bioconda-utils` be set up and used according to the
instructions at https://bioconda.github.io/contributor/index.html. This will
ensure that your local setup matches that used to build recipes on travis-ci as
closely as possible.

However, if you would like to test in a standalone manner or help develop
bioconda-utils, you can install requirements via conda into your root conda
environment and then install the package:

```bash
conda install --file bioconda_utils/bioconda_utils-requirements.txt -c conda-forge -c bioconda 
python setup.py install
```

See the help for the `bioconda-utils` command-line interface for details:

```
bioconda-utils -h
```
