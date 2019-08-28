#!/usr/bin/env bash

cat > "${PREFIX}"/.messages.txt <<- EOF
    
    ##############################################################################
    #                                                                            #
    #   Note: while Conda has installed AMPtk and all of its depenencies that    #
    #      it can, you will still need to download the usearch9 and usearch10    #
    #      binaries and make sure they are in your PATH. They should be          #
    #      softlinked to usearch9 and usearch10 respectively, i.e.               #
    #                                                                            #
    #      chmod +x /path/to/usearch9.2.64_i86osx32                              #
    #      ln -s /path/to/usearch9.2.64_i86osx32 /usr/local/bin/usearch9         #
    #                                                                            #
    ##############################################################################
EOF