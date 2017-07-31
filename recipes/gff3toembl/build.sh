#!/bin/bash


set -x
set -e

start_dir=$(pwd)

GENOMETOOLS_VERSION="1.5.9"

GENOMETOOLS_DOWNLOAD_URL="https://github.com/genometools/genometools/archive/v${GENOMETOOLS_VERSION}.tar.gz"

# Make an install location
if [ ! -d 'build' ]; then
  mkdir build
fi
cd build
build_dir=$(pwd)

# DOWNLOAD ALL THE THINGS
download () {
  url=$1
  download_location=$2

  if [ -e $download_location ]; then
    echo "Skipping download of $url, $download_location already exists"
  else
    echo "Downloading $url to $download_location"
    wget $url -O $download_location
  fi
}

download $GENOMETOOLS_DOWNLOAD_URL "genometools-${GENOMETOOLS_VERSION}.tgz"

# Update dependencies
if [ "$TRAVIS" = 'true' ]; then
  echo "Using Travis's apt plugin"
else
  sudo apt-get update -q
  sudo apt-get install -y -q g++ \
  		             python-dev
fi

# Build all the things
cd $build_dir

## GenomeTools
genometools_dir=$(pwd)/genometools-${GENOMETOOLS_VERSION}
if [ ! -d $genometools_dir ]; then
  tar xzf genometools-${GENOMETOOLS_VERSION}.tgz
fi
cd $genometools_dir
if [ -e "${genometools_dir}/bin/gt" ]; then
  echo "Already built GenomeTools; skipping build"
else
  make cairo=no
fi

cd $build_dir

# Setup environment variables
update_path () {
  new_dir=$1
  export PATH=${PATH:-$new_dir}
  if [[ ! "$PATH" =~ (^|:)"${new_dir}"(:|$) ]]; then
    export PATH=${new_dir}:${PATH}
  fi
}

update_path ${genometools_dir}/bin

update_python_path () {
  new_dir=$1
  export PYTHONPATH=${PYTHONPATH:-$new_dir}
  if [[ ! "$PYTHONPATH" =~ (^|:)"${new_dir}"(:|$) ]]; then
    export PYTHONPATH=${new_dir}:${PYTHONPATH}
  fi
}

update_python_path ${genometools_dir}/gtpython

update_ld_path () {
  new_dir=$1
  export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-$new_dir}
  if [[ ! "$LD_LIBRARY_PATH" =~ (^|:)"${new_dir}"(:|$) ]]; then
    export LD_LIBRARY_PATH=${new_dir}:${LD_LIBRARY_PATH}
  fi
}

update_ld_path ${genometools_dir}/lib

cd $start_dir

set +x
set +e







$PYTHON setup.py install
