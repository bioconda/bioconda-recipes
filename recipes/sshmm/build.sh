#!/bin/bash

cd $CONDA_PREFIX
mkdir -p ./etc/conda/activate.d
mkdir -p ./etc/conda/deactivate.d
echo -e "#!/bin/sh\n\nexport DATAPATH=$CONDA_PREFIX/share/rnastructure/data_tables/" > ./etc/conda/activate.d/env_vars.sh
echo -e "#!/bin/sh\n\nexport DATAPATH=" > ./etc/conda/deactivate.d/env_vars.sh

pip install sshmm
