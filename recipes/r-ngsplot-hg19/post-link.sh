#!/bin/bash
FN="ngsplotdb_hg19_75_3.00.tar.gz"
URLS=(
  "https://doc-0g-a0-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/jiksn2m41cm3dbspq0nqt102h6m6eo1o/1528221600000/01382619737792242945/*/0B5hDZ2BucCI6SURYWW5XdUxnbW8?e=download"
)
sha256="a3ad6daceec383f88faf3d3ee899f2bef37b3be2658ee9afa01e86404c0c92bd"

# Use a staging area in the conda dir rather than temp dirs, both to avoid
# permission issues as well as to have things downloaded in a predictable
# manner.
STAGING=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $STAGING
TARBALL=$STAGING/$FN

SUCCESS=0
for URL in ${URLS[@]}; do
  wget -O- -q $URL > $TARBALL
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
  echo "ERROR: post-link.sh was unable to download any of the following URLs with the md5sum $MD5:"
  printf '%s\n' "${URLS[@]}"
  exit 1
fi

# Install and clean up
ngsplotdb.py install "${TARBALL}" > "${PREFIX}/.messages.txt" 2>&1
rm $TARBALL
rmdir $STAGING