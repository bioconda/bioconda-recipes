![](https://raw.githubusercontent.com/bioconda/bioconda-recipes/master/logo/bioconda_monochrome_small.png
 "Bioconda")

# The bioconda channel

[![Gitter](https://badges.gitter.im/bioconda/bioconda-recipes.svg)](https://gitter.im/bioconda/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

[Conda](http://anaconda.org) is a platform- and language-independent package
manager that supports easy distribution, installation and version management of
software. The [bioconda channel](https://anaconda.org/bioconda) is a Conda
channel providing bioinformatics related packages for **Linux** and **macOS**, 
supporting both x86_64 and aarch64/arm64 architectures.
This repository hosts the corresponding recipes.

## User guide

Please visit https://bioconda.github.io for details. 

## Developer guide

Please visit the new docs at https://bioconda.github.io/contributor/index.html for details.

## Nightly build status
The nightly uploader jobs build any recipes that exist on master but were not successfully uploaded to the [bioconda channel](https://anaconda.org/bioconda). Any failure in the nightly build should be resolved with a PR for the affected recipe.

| arch | build status |
|------|--------------|
| linux-64 | [![Nightly linux-64](https://dev.azure.com/bioconda/bioconda-recipes/_apis/build/status/Nightly%20uploader?branchName=master&jobName=build_and_push_linux&label=Nightly%20linux-64)](https://dev.azure.com/bioconda/bioconda-recipes/_build/latest?definitionId=4) |
| osx-64 | [![Nightly osx-64](https://dev.azure.com/bioconda/bioconda-recipes/_apis/build/status/Nightly%20uploader?branchName=master&jobName=build_and_push_osx&label=Nightly%20osx-64)](https://dev.azure.com/bioconda/bioconda-recipes/_build/latest?definitionId=4) |
| osx-arm64 | [![Nightly osx-arm64](https://github.com/bioconda/bioconda-recipes/actions/workflows/nightly.yml/badge.svg)](https://github.com/bioconda/bioconda-recipes/actions/workflows/nightly.yml) |
| linux-aarch64 |[![CircleCI](https://dl.circleci.com/insights-snapshot/gh/bioconda/bioconda-recipes/master/Nightly%20(ARM)/badge.svg?window=24h)](https://app.circleci.com/insights/github/bioconda/bioconda-recipes/workflows/Nightly%20(ARM)/overview?branch=master&reporting-window=last-24-hours) |
