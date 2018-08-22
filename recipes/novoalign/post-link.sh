#!/bin/bash

MSGS=$PREFIX/.messages.txt
touch $MSGS
echo 'Novoalign is installed.  Commercial use requires a license; contact sales@novocraft.com.  License also adds' >> $MSGS
echo 'multi-threading and other features.' >> $MSGS

echo 'Once you have a license file, run novoalign-license-register to install it.' >> $MSGS


echo 'Licensing information from Novocraft website:' >> $MSGS
echo >> $MSGS
echo '-----------------------------------------------' >> $MSGS
# Novocraft normally does not permit distribution of novoalign to third parties.
# They made an exception for Bioconda (and Homebrew), with the condition that
# each user installation through Bioconda trigger an access to Novocraft's website,
# so they can track commercial users.
curl --silent -L http://www.novocraft.com/bioconda/license.txt >> $MSGS 2>&1
echo '-----------------------------------------------' >> $MSGS
