#!/bin/bash

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/share/amplify/
mkdir -p ${PREFIX}/share/amplify/src/
mkdir -p ${PREFIX}/share/amplify/models/
cp -r src/. ${PREFIX}/share/amplify/src
cp -r models/. ${PREFIX}/share/amplify/models

echo "#!/bin/bash" > ${PREFIX}/bin/AMPlify
echo "${PREFIX}/share/amplify/src/AMPlify.py \$@" >> ${PREFIX}/bin/AMPlify

echo "#!/bin/bash" > ${PREFIX}/bin/train_amplify
echo "${PREFIX}/share/amplify/src/train_amplify.py \$@" >> ${PREFIX}/bin/train_amplify
