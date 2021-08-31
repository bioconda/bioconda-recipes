#!/bin/bash
FN="BSgenome.Celegans.UCSC.ce11_1.4.2.tar.gz"
URLS=(
  "https://bioconductor.org/packages/3.13/data/annotation/src/contrib/BSgenome.Celegans.UCSC.ce11_1.4.2.tar.gz"
  "https://bioarchive.galaxyproject.org/BSgenome.Celegans.UCSC.ce11_1.4.2.tar.gz"
  "https://depot.galaxyproject.org/software/bioconductor-bsgenome.celegans.ucsc.ce11/bioconductor-bsgenome.celegans.ucsc.ce11_1.4.2_src_all.tar.gz"
  "https://depot.galaxyproject.org/software/bioconductor-bsgenome.celegans.ucsc.ce11/bioconductor-bsgenome.celegans.ucsc.ce11_1.4.2_src_all.tar.gz"
)
MD5="b80e24149a0c6ed323d0c9a6d112ef52"

# Use a staging area in the conda dir rather than temp dirs, both to avoid
# permission issues as well as to have things downloaded in a predictable
# manner.
STAGING=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $STAGING
TARBALL=$STAGING/$FN

SUCCESS=0
for URL in ${URLS[@]}; do
  curl $URL > $TARBALL
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
R CMD INSTALL --library=$PREFIX/lib/R/library $TARBALL
rm $TARBALL
rmdir $STAGING
