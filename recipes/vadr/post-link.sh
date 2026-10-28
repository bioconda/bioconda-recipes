#!/usr/bin/env bash

echo "
Please run 'download-vadr-models.sh MODELNAME' (e.g. 'download-vadr-models.sh sarscov2')
to download the models required to run VADR. These files will be downloaded to ${VADRMODELDIR}. 
A list of avaialble models can be found at https://ftp.ncbi.nlm.nih.gov/pub/nawrocki/vadr-models/ 
If you have a database in a custom path, please change the VADRMODELDIR environment variable.
" >> ${PREFIX}/.messages.txt
printf '%s\n' "${URLS[@]}" >> "${PREFIX}/.messages.txt" 2>&1
