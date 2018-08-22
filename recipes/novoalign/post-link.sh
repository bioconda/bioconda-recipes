#!/bin/bash

echo 'Novoalign is installed.  Commercial use requires a license; contact sales@novocraft.com.  License also adds'
echo 'multi-threading and other features.'

echo 'Once you have a license file, run novoalign-license-register to install it.'


echo 'Licensing information from Novocraft website:'
echo
# Novocraft normally does not permit distribution of novoalign to third parties.
# They made an exception for Bioconda (and Homebrew), with the condition that
# each user installation through Bioconda trigger an access to Novocraft's website,
# so they can track commercial users.
curl -L http://www.novocraft.com/bioconda/license.txt
