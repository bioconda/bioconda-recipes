#!/bin/bash

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
cp -f migmap-0.9.7.jar $PREFIX/lib

cat > $PREFIX/bin/migmap << EOT

#!/bin/bash
# migmap runner script
if [[ "$@" == *'--data-dir'* ]]; then 
    java -jar $CONDA_ENV_HOME/lib/migmap-0.9.7.jar "$@" # just pass command line arguments
else
    java -jar $CONDA_ENV_HOME/lib/migmap-0.9.7.jar --data-dir $IGDATA "$@" # set by igblast package
fi

EOT

chmod +x $PREFIX/bin/migmap
