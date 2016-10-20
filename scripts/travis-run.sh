#!/bin/bash
set -euo pipefail
export PATH=/anaconda/bin:$PATH
if [[ $TRAVIS_OS_NAME = "linux" ]]
then
    docker run -e SUBDAG -e SUBDAGS -e TRAVIS_BRANCH -e TRAVIS_PULL_REQUEST -e ANACONDA_TOKEN -e BIOCONDA_UTILS_ARGS \
               -v `pwd`:/bioconda-recipes condaforge/linux-anvil /bin/bash -c \
               "cd /bioconda-recipes; conda install --file scripts/requirements.txt; pip install git+https://github.com/bioconda/bioconda-utils.git@$BIOCONDA_UTILS_TAG; pip install git+https://github.com/bioconda/conda-build.git@fix-build-skip-existing; set -x; bioconda-utils build recipes config.yml $BIOCONDA_UTILS_ARGS; set +x"

    if [[ $SUBDAG = 0 ]]
    then
      if [[ $TRAVIS_BRANCH = "master" && "$TRAVIS_PULL_REQUEST" = false ]]
      then
        # build package documentation
        scripts/build-docs.sh
      fi
    fi
else
    # build packages
    #scripts/build-packages.py --repository . --env-matrix scripts/env_matrix.yml
    pip install git+https://github.com/bioconda/conda-build.git@fix-build-skip-existing
    bioconda-utils build recipes config.yml $BIOCONDA_UTILS_ARGS
fi
