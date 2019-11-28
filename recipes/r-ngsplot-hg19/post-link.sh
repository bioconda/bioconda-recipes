#!/bin/bash
FN="ngsplotdb_hg19_75_3.00.tar.gz"
URLS=(
  "https://drive.google.com/uc?export=download&id=0B5hDZ2BucCI6SURYWW5XdUxnbW8"
)
MD5="172a6a93de3d1ae8a3ad6d6d79e911f7"

# Use a staging area in the conda dir rather than temp dirs, both to avoid
# permission issues as well as to have things downloaded in a predictable
# manner.
STAGING=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $STAGING
TARBALL=$STAGING/$FN

SUCCESS=0
for URL in ${URLS[@]}; do
  wget -O- -q ${URL} > $TARBALL
  [[ $? == 0 ]] || continue

  # Platform-specific md5sum checks.
  if [[ $(uname -s) == "Linux" ]]; then
    if md5sum -c <<<"$MD5  $TARBALL"; then
      SUCCESS=1
      break
    fi
  else if [[ $(uname -s) == "Darwin" ]]; then
    if [[ $(md5 $TARBALL | cut -f4 -d " ") == "$MD5" ]]; then
      SUCCESS=1
      break
    fi
  fi
fi
done

if [[ $SUCCESS != 1 ]]; then
  echo "ERROR: post-link.sh was unable to download any of the following URLs with the md5sum $MD5:" >> "${PREFIX}/.messages.txt" 2>&1
  printf '%s\n' "${URLS[@]}" >> "${PREFIX}/.messages.txt" 2>&1
  exit 1
fi

# Install and clean up
ngsplotdb.py -y install "${TARBALL}" >> "${PREFIX}/.messages.txt" 2>&1
rm $TARBALL
rmdir $STAGING
