#!/bin/bash
FN="pd.charm.hg18.example_0.99.4.tar.gz"
URLS=(
  "https://bioconductor.org/packages/3.11/data/annotation/src/contrib/pd.charm.hg18.example_0.99.4.tar.gz"
  "https://bioarchive.galaxyproject.org/pd.charm.hg18.example_0.99.4.tar.gz"
  "https://depot.galaxyproject.org/software/bioconductor-pd.charm.hg18.example/bioconductor-pd.charm.hg18.example_0.99.4_src_all.tar.gz"
  "https://depot.galaxyproject.org/software/bioconductor-pd.charm.hg18.example/bioconductor-pd.charm.hg18.example_0.99.4_src_all.tar.gz"
)
MD5="e201d4281a23c202f57bae1135e226b4"

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
