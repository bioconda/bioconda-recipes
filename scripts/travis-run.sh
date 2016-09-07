#!/bin/bash
set -euo pipefail

if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    docker run -e SUBDAG -e SUBDAGS -e TRAVIS_BRANCH -e TRAVIS_PULL_REQUEST -e ANACONDA_TOKEN \
               -v `pwd`:/bioconda-recipes condaforge/linux-anvil /bin/bash -c \
               "cd /bioconda-recipes; conda install --file scripts/requirements.txt; pip install git+https://github.com/bioconda/bioconda-utils.git@$BIOCONDA_UTILS_TAG; pip install git+https://github.com/bioconda/conda-build.git@v2.0.1-fix-output+skip; bioconda-utils build recipes config.yml --loglevel=info"

    if [[ $SUBDAG = 0 ]]
    then
      if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = false ]]
      then
        # build package documentation
        scripts/build-docs.sh
      fi
    fi
else
    export PATH=/anaconda/bin:$PATH
    # build packages
    #scripts/build-packages.py --repository . --env-matrix scripts/env_matrix.yml
    pip install git+https://github.com/bioconda/conda-build.git@v2.0.1-fix-output+skip
    bioconda-utils build recipes config.yml --loglevel=info
fi
