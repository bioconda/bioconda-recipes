#!/bin/bash

CHECKM_ROOT_DIR=${CHECKM_DATA_DIR:=$PREFIX/checkm_data}
mkdir -p $CHECKM_ROOT_DIR
if [[ -r $CHECKM_ROOT_DIR/genome_tree/genome_tree.derep.txt ]]; then
  echo "Using checkm data at $CHECKM_ROOT_DIR" >> $PREFIX/.messages.txt
else
  FN="checkm_data_2015_01_16.tar.gz"
  URL="https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz"
  SHA256="971ec469348bd6c3d9eb96142f567f12443310fa06c1892643940f35f86ac92c"

  # Create staging area.
  STAGING=$PREFIX/staging
  TARBALL=$STAGING/$FN

  SUCCESS=0

  # Make directory for staging.
  mkdir -p $STAGING

  if [[ ! -z "${CHECKM_DATA_PATH}" && -f "${CHECKM_DATA_PATH}" ]]; then
    # Grab tarball from local filesystem.
    cp $CHECKM_DATA_PATH $TARBALL
  else
    # Download tarball.
    wget --no-check-certificate -O $TARBALL $URL
  fi

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
  tar -C $CHECKM_ROOT_DIR -zxvf $TARBALL

  # Remove staging directory.
  rm -r $STAGING
fi

# Add data location to checkm config
checkm data setRoot $CHECKM_ROOT_DIR

echo "checkm data setRoot $CHECKM_ROOT_DIR" >> $PREFIX/.messages.txt
