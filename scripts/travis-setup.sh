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
    mkdir -p /tmp/anaconda/conda-bld/osx-64 # workaround for bug in current conda
    bash Miniconda3-latest-MacOSX-x86_64.sh -b -p /anaconda
    export PATH=/anaconda/bin:$PATH
    conda install -y conda conda-build anaconda-client pyyaml toolz jinja2 nose

    # setup bioconda channel
    conda config --add channels bioconda
    conda config --add channels r

    conda install -y toposort
fi
