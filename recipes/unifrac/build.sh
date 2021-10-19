#!/bin/bash
set +ex
export USE_CYTHON=True
export PERFORMING_CONDA_BUILD=True
export LIBRARY_PATH="${CONDA_PREFIX}/lib"
export LD_LIBRARY_PATH=${LIBRARY_PATH}:${LD_LIBRARY_PATH}
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include"

if [[ "$(uname -s)" != "Linux" ]];
then
  ls -l /Applications/
  # coonda clang does not like xcode 12
  sudo xcode-select --switch /Applications/Xcode_11.7.app
  # the system tools are unusable, hide them
  sudo mv -f /Library/Developer/CommandLineTools /Library/Developer/CommandLineTools.org
fi

conda create --yes -n unifrac -c conda-forge -c bioconda python=3.6
conda activate unifrac
conda config --add channels conda-forge
conda config --add channels bioconda

if [[ "$(uname -s)" == "Linux" ]];
then
  conda install --yes -c conda-forge -c bioconda gxx_linux-64=7.5.0
else
  conda install --yes -c conda-forge -c bioconda clangxx_osx-64=10.0.0
fi 
conda install --yes -c conda-forge -c bioconda cython "hdf5>=1.8.17" biom-format numpy "h5py>=2.7.0" "scikit-bio>=0.5.1" flake8 nose
conda install --yes -c conda-forge -c bioconda mkl-include lz4 hdf5-static

if [[ "$(uname -s)" == "Linux" ]];
then
  which x86_64-conda-linux-gnu-gcc
  x86_64-conda-linux-gnu-gcc -v
  x86_64-conda-linux-gnu-g++ -v
else
  conda install --yes liblapacke
  which clang
  clang -v
fi

if [[ "$(uname -s)" == "Linux" ]];
then
  ./scripts/install_hpc_sdk.sh
  source setup_nv_h5.sh
fi

pushd sucpp
make main
make api
popd

$PYTHON -m pip install --no-deps --ignore-installed .
