#!/bin/bash

set -xe

# TODO: Remove the following export when pinning is updated and we use
#       {{ compiler('rust') }} in the recipe.
export \
	CARGO_NET_GIT_FETCH_WITH_CLI=true \
	CARGO_HOME="${BUILD_PREFIX}/.cargo"

cp $RECIPE_DIR/build_htslib.sh d4-hts/build_htslib.sh

cd d4binding 
./install.sh
