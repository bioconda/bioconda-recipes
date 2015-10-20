#!/bin/bash
set -e

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    docker pull bioconda/bioconda-builder
else
    # install Rust
    curl -sSf http://static.rust-lang.org/rustup.sh | sh -s -- --channel=nightly -y --disable-sudo

    # install conda
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
    bash Miniconda3-latest-MacOSX-x86_64.sh -b -p /tmp/anaconda
    mkdir -p /tmp/anaconda/conda-bld/osx-64 # workaround for bug in current conda
    export PATH=/tmp/anaconda/bin:$PATH
    conda install -y conda conda-build anaconda-client pyyaml toolz jinja2 nose
    conda index /tmp/anaconda/conda-bld/

    # setup bioconda channel
    conda config --add channels bioconda
    conda config --add channels r
    conda config --add channels file://tmp/anaconda/conda-bld/

    conda install -y toposort
fi
