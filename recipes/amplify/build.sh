#!/bin/bash

mkdir -p ${PREFIX}/bin/
mkdir -p ${PREFIX}/share/amplify/
mkdir -p ${PREFIX}/share/amplify/src/
mkdir -p ${PREFIX}/share/amplify/models/
cp -r src/. ${PREFIX}/share/amplify/src/
cp -r models/. ${PREFIX}/share/amplify/models/

echo "#!/bin/bash" > ${PREFIX}/bin/AMPlify
echo "${PREFIX}/share/amplify/src/AMPlify.py \$@" >> ${PREFIX}/bin/AMPlify

echo "#!/bin/bash" > ${PREFIX}/bin/train_amplify
echo "${PREFIX}/share/amplify/src/train_amplify.py \$@" >> ${PREFIX}/bin/train_amplify

python3.6 --version

python3.6 -m pip install --no-deps --ignore-installed -vv https://files.pythonhosted.org/packages/22/cc/ca70b78087015d21c5f3f93694107f34ebccb3be9624385a911d4b52ecef/tensorflow-1.12.0-cp36-cp36m-manylinux1_x86_64.whl
