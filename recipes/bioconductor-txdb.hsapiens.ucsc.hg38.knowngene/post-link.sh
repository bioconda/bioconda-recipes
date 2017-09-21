#!/bin/bash

FN="TxDb.Hsapiens.UCSC.hg38.knownGene_3.4.0.tar.gz"
URLS=(
    "https://depot.galaxyproject.org/software/TxDb.Hsapiens.UCSC.hg38.knownGene/TxDb.Hsapiens.UCSC.hg38.knownGene_3.4.0_src_all.tar.gz"
    "http://bioconductor.org/packages/3.5/data/annotation/src/contrib/TxDb.Hsapiens.UCSC.hg38.knownGene_3.4.0.tar.gz"
    )
MD5="1d5e07631ea58e96b11905d39e76ca6e"

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
  if [[ $(uname -s) == "Linux" ]]; then
    if [[ $(md5sum -c <<<"$MD5  $TARBALL") ]]; then
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

R CMD INSTALL --build $TARBALL
rm $TARBALL
