#!/bin/bash

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/share/amplify
cp -r src/. ${PREFIX}/share/amplify

echo "#!/bin/bash" > ${PREFIX}/bin/AMPlify
echo "${PREFIX}/share/amplify/AMPlify.py \$@" >> ${PREFIX}/bin/AMPlify

echo "#!/bin/bash" > ${PREFIX}/bin/train_amplify
echo "${PREFIX}/share/amplify/train_amplify.py \$@" >> ${PREFIX}/bin/train_amplify
