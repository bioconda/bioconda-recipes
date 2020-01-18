#!/usr/bin/env bash

cat > "${PREFIX}"/.messages.txt <<- EOF

	# pbmarkdup
	##############################################################################
	#                                                                            #
	# PacBio(R) tools distributed via Bioconda are: pre-release versions, not    #
	# necessarily ISO compliant, intended for Research Use Only and not for use  #
	# in diagnostic procedures, intended only for command-line users, and        #
	# possibly newer than the currently available SMRT(R) Analysis builds. While #
	# efforts have been made to ensure that releases on Bioconda live up to the  #
	# quality that PacBio strives for, we make no warranty regarding any         #
	# Bioconda release.                                                          #
	#                                                                            #
	# As PacBio tools distributed via Bioconda are not covered by any service    #
	# level agreement or the like, please *do not* contact a PacBio Field        #
	# Applications Scientist or PacBio Customer Service for assistance with any  #
	# Bioconda release. We instead provide an issue tracker for you to report    #
	# issues to us at:                                                           #
	#                                                                            #
	#   https://github.com/PacificBiosciences/pbbioconda                         #
	#                                                                            #
	# We make no warranty that any such issue will be addressed,                 #
	# to any extent or within any time frame.                                    #
	#                                                                            #
	# BSD 3-Clause Clear License                                                 #
	#                                                                            #
	# Please see https://github.com/PacificBiosciences/pbbioconda for            #
	# information on License, Copyright and Disclaimer                           #
	#                                                                            #
	##############################################################################
EOF
