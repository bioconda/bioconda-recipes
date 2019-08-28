#!/usr/bin/env bash

set -eu -o pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then

    cat > "${PREFIX}"/.messages.txt <<- EOF
    
	#############################################################################################
	#                                                                                           #
	#   Note: SPAdes installed through bioconda on MacOS may be somewhat slower than the SPAdes #
	#   binaries distributed by the authors at                                                  #
	#                                                                                           #
	#   http://cab.spbu.ru/files/release${PKG_VERSION}/SPAdes-${PKG_VERSION}-Darwin.tar.gz
	#                                                                                           #
	#   due to unavailability of parallel libstdc++ for the Clang compiler used by bioconda on  #
	#   MacOS; see https://github.com/ablab/spades/issues/194#issuecomment-523175204            #
	#                                                                                           #
	#############################################################################################
EOF
fi
