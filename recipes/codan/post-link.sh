#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then

    cat > "${PREFIX}"/.messages.txt <<- EOF
    
	#############################################################################################
	#                                                                                           #
	#   Note: CodAn installed through bioconda on MacOS may have some erros during conda        #
	#   installation.                                                                           #
  #   Conda may not be able to replace the tops-viterbi_decoding script necessary to perform  #
  #   predictions. It can cause errors, but can be easily solved by following the steps below:# 
	#                                                                                           #
	#   Please, go to CodAn github repostory: https://github.com/pedronachtigall/CodAn          #
  #   Download the zip file "for_MacOS_users.zip"                                             #
  #   Decompress the file: "unzip for_MacOS_users.zip"                                        #
  #   Apply "execution permission": "chmod +x unzip for_MacOS_users/tops-viterbi_decoding"    #
  #   Replace the tops in the env:                                                            #
  #   "cp for_MacOS_users/tops-viterbi_decoding ${PREFIX}/envs/ENVNAME/bin/"                  #
  #           - whereas ENVNAME = name of the environment with CodAn                          #
	#                                                                                           #
	#############################################################################################
EOF
fi
