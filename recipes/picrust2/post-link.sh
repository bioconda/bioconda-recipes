#!/bin/bash

FN="v2.1.2-b.tar.gz"
TARBALL_DIR="picrust2-2.1.2-b"
URL="https://github.com/picrust/picrust2/archive/v2.1.2-b.tar.gz"
SHA256="ed7ab5b49ebda36f806c17fbbb46d4947ae24699870bc1d1a7dbfb26bb6f4b39" 

# Create staging area.
STAGING=$PREFIX/staging
TARBALL=$STAGING/$FN

SUCCESS=0

# Make directory for staging.
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

# Move default database files to expected directory.
tar -C $STAGING -zxvf $TARBALL

PYTHON_INSTALL_DIR=`python -c "import site; print(site.getsitepackages()[0])"`

mv $STAGING/$TARBALL_DIR/picrust2/default_files $PYTHON_INSTALL_DIR/picrust2

# Remove staging directory.
rm -r $STAGING

