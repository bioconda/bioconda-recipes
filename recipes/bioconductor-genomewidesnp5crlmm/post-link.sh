#!/bin/bash
FN="genomewidesnp5Crlmm_1.0.6.tar.gz"
URLS=(
  "https://bioconductor.org/packages/3.13/data/annotation/src/contrib/genomewidesnp5Crlmm_1.0.6.tar.gz"
  "https://bioarchive.galaxyproject.org/genomewidesnp5Crlmm_1.0.6.tar.gz"
  "https://depot.galaxyproject.org/software/bioconductor-genomewidesnp5crlmm/bioconductor-genomewidesnp5crlmm_1.0.6_src_all.tar.gz"
  "https://depot.galaxyproject.org/software/bioconductor-genomewidesnp5crlmm/bioconductor-genomewidesnp5crlmm_1.0.6_src_all.tar.gz"
)
MD5="cc24140cd17758b8e09f4fe6c931526a"

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
