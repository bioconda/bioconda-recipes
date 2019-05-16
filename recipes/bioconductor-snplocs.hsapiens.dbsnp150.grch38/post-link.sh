#!/bin/bash
FN="SNPlocs.Hsapiens.dbSNP150.GRCh38_0.99.20.tar.gz"
URLS=(
  "https://bioconductor.org/packages/3.9/data/annotation/src/contrib/SNPlocs.Hsapiens.dbSNP150.GRCh38_0.99.20.tar.gz"
  "https://bioarchive.galaxyproject.org/SNPlocs.Hsapiens.dbSNP150.GRCh38_0.99.20.tar.gz"
  "https://depot.galaxyproject.org/software/bioconductor-snplocs.hsapiens.dbsnp150.grch38/bioconductor-snplocs.hsapiens.dbsnp150.grch38_0.99.20_src_all.tar.gz"
  "https://depot.galaxyproject.org/software/bioconductor-snplocs.hsapiens.dbsnp150.grch38/bioconductor-snplocs.hsapiens.dbsnp150.grch38_0.99.20_src_all.tar.gz"
)
MD5="575a7aaa9125d52ca0634b3ac586c9a7"

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
