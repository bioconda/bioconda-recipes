#!/bin/bash

FN="picrust2-2.0.4-b.tar.gz"
TARBALL_DIR="picrust2-2.0.4-b"
URL="https://github.com/picrust/picrust2/releases/download/v2.0.4-b/picrust2-2.0.4-b.tar.gz"

# Create staging area.
STAGING=$PREFIX/staging
TARBALL=$STAGING/$FN
SHA256="b0d12da6aa072b7279e2c82afd09152f33dd016f5204a8ef055196f5e501ae19"

SUCCESS=0

mkdir -p $STAGING

# Download tarball.
wget -O $TARBALL $URL

# Check that sha256sum matches expected.
# Different commands depending on platform.
if [[ $(uname -s) == "Linux" ]]; then
    if sha256sum -c <<< "$SHA256  $TARBALL"; then
      SUCCESS=1
    fi
  else if [[ $(uname -s) == "Darwin" ]]; then
    if [[ $(shasum -a 256 $TARBALL | awk '{ print $1 }') == "$SHA256" ]]; then
      SUCCESS=1
    fi
  fi
fi

# Throw error if unable to match sha256 correctly.
if [[ $SUCCESS != 1 ]]; then
  echo "ERROR: post-link.sh was unable to download $TARBALL with the sha256 $SHA256 from $URL." >> $PREFIX/.messages.txt
  exit 1
fi

# Copy required Rscripts and default database files to appropriate folders.
tar -C $STAGING -zxvf $TARBALL

PYTHON_INSTALL_DIR=`python -c "import site; print(site.getsitepackages()[0])"`

mv $STAGING/$TARBALL_DIR/picrust2/default_files $PYTHON_INSTALL_DIR/picrust2
mv $STAGING/$TARBALL_DIR/picrust2/MinPath $PYTHON_INSTALL_DIR/picrust2
mv $STAGING/$TARBALL_DIR/picrust2/Rscripts $PYTHON_INSTALL_DIR/picrust2

# Remove staging directory.
rm -r $STAGING

