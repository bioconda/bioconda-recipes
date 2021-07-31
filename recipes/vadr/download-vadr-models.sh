#! /usr/bin/env bash
MODELNAME=$1


# If no model given, print help message
if [[ -z ${MODELNAME+x} ]]; then
    echo "usage: download-vadr-models.sh MODEL_NAME"
    echo ""
    echo "MODEL_NAME can be one of the following: sarscov2, caliciviridae, coronaviridae, cox1, flaviviridae"
    echo ""
    echo "Example: download-vadr-models.sh sarscov2"
    echo ""
    echo "To get an updated list of available models please visit https://ftp.ncbi.nlm.nih.gov/pub/nawrocki/vadr-models/"
    exit 1
fi

# Covert VADR version to Model version (e.g. 1.2.1 -> 1.2-1)
MVERSION=$(echo $VADRVERSION | sed -r 's/([0-9]).([0-9]).([0-9])/\1.\2-\3/')

# Download model
CURRENT_DIR=$(pwd)
mkdir -p ${VADRMODELDIR}/tmp
cd $VADRMODELDIR/tmp
wget -O vadr-models-${MODELNAME}.tar.gz https://ftp.ncbi.nlm.nih.gov/pub/nawrocki/vadr-models/${MODELNAME}/${MVERSION}/vadr-models-${MODELNAME}-${MVERSION}.tar.gz
tar -xfz vadr-models-${MODELNAME}.tar.gz
mv vadr-models-$v-$MVERSION/* ${VADRMODELDIR}/
rm -rf $VADRMODELDIR/tmp
cd $(CURRENT_DIR)
