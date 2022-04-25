#!/bin/bash
FN="ChIPexoQualExample_1.18.0.tar.gz"
URLS=(
  "https://bioconductor.org/packages/3.14/data/experiment/src/contrib/ChIPexoQualExample_1.18.0.tar.gz"
  "https://bioarchive.galaxyproject.org/ChIPexoQualExample_1.18.0.tar.gz"
  "https://depot.galaxyproject.org/software/bioconductor-chipexoqualexample/bioconductor-chipexoqualexample_1.18.0_src_all.tar.gz"
)
MD5="e42392583c264ef72600dd820d99bf2f"

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
