#!/bin/bash
set -ex

df -h

ls -l

ls -l ..

# Setup PLAST binaries
if [[ $(uname) == "Darwin" ]]; then
  cd ../plastbinary_osx_v2.3.2
elif [[ $(uname) == "Linux" ]]; then
  cd ../plastbinary_linux_v2.3.2
else
  echo "Unsupported architecture!"
  exit 1
fi

cp build/bin/plast $PREFIX/bin/
cd ../Eukfinder

# Clone acc2tax repository
git clone https://github.com/richardmleggett/acc2tax.git
echo "acc2tax downloaded successfully"

# Build acc2tax
cd acc2tax
# According to https://bioconda.github.io/contributor/troubleshooting.html
# and https://github.com/bioconda/bioconda-recipes/pull/49360#discussion_r1686187284
$(which "$CC") -o acc2tax acc2tax.c
cp acc2tax $PREFIX/bin/
cd ..

chmod +x $PREFIX/bin/plast
chmod +x $PREFIX/bin/acc2tax

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

df -h