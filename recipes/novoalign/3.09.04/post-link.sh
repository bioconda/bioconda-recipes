#!/bin/bash

MSGS=$PREFIX/.messages.txt
touch $MSGS

function msg {
    echo $1 >> $MSGS 2>&1
}

msg
msg '========================= Novoalign information ==========================================='
msg 'Novoalign is installed.  Documentation installed in'
msg "${PREFIX}/share/doc/novoalign"
msg
msg 'Commercial use requires a license; contact sales@novocraft.com.'
msg 'License also adds multi-threading and other features.'

msg 'Once you have a license file, run novoalign-license-register to install it.'

msg
msg 'Licensing information from Novocraft website:'
msg '--------------------------------------------------------------------------------------------'
# Novocraft normally does not permit distribution of novoalign to third parties.
# They made an exception for Bioconda (and Homebrew), with the condition that
# each user installation through Bioconda trigger an access to Novocraft's website,
# so they can track commercial users.
curl --fail --silent -L http://www.novocraft.com/bioconda/license.txt >> $MSGS 2>&1
msg '======================== End of novoalign information ======================================'
