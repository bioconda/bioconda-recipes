#!/bin/bash

cat > "${PREFIX}"/.messages.txt <<- EOF
    
  ##############################################################################################
  #                                                                                            #
  #   If you don't know how to use CodAn, please follow the tutorial available at GitHub:      #
  #       - https://github.com/pedronachtigall/CodAn/tree/master/tutorial                      #
  #                                                                                            #
  #   Please, notice that you still need to download the models available at GitHub:           # 
  #       - https://github.com/pedronachtigall/CodAn/tree/master/models                        #
  #       - The models can be downloaded directly from GitHub and decompressed (unzip)         #
  #       - OR the user can take advantage of wget command:                                    #
  #          - wget https://github.com/pedronachtigall/CodAn/raw/master/models/<model>.zip     #
  #          - unzip <model>.zip                                                               #
  #       - the models available are:                                                          #
  #          - FUNGI_full and FUNGI_partial -> models designed to FUNGI species                #
  #          - INV_full and INV_partial -> models designed to INVERTEBRATE species             #
  #          - PLANTS_full and PLANTS_partial -> models designed to PLANT species              #
  #          - VERT_full and VERT_partial -> models designed to VERTEBRATE species             #
  #                                                                                            #
  ##############################################################################################
EOF
