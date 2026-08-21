#!/bin/bash
set -ex
# takes a single parameter, the package name

SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )/../share/bioconductor-data-packages"
json="${SCRIPT_DIR}/dataURLs.json"
FN=`yq ".\"$1\".fn" "${json}"`
##readarray is bash4, while OSX only has bash 3
#readarray URLS < <(yq ".\"$1\".urls[]" "${json}")
while IFS= read -r value; do
  URLS+=($value);
done < <(yq ".\"$1\".urls[]" "${json}")
MD5=`yq ".\"$1\".md5" "${json}"`

# Use a staging area in the conda dir rather than temp dirs, both to avoid
# permission issues as well as to have things downloaded in a predictable
# manner.
STAGING=$PREFIX/share/"$1"
mkdir -p $STAGING
TARBALL=$STAGING/$FN

# Set URLs from environment variables or use provided defaults
BIOCONDUCTOR_URL="${BIOCONDUCTOR_MIRROR:-"https://bioconductor.org"}"
GALAXY_BIOARCHIVE_URL="${GALAXY_BIOARCHIVE_MIRROR:-"https://bioarchive.galaxyproject.org"}"
GALAXY_DEPOT_URL="${GALAXY_DEPOT_MIRROR:-"https://depot.galaxyproject.org"}"

# Remove trailing slashes
BIOCONDUCTOR_URL=`echo $BIOCONDUCTOR_URL | sed 's#/$##'`
GALAXY_BIOARCHIVE_URL=`echo $GALAXY_BIOARCHIVE_URL | sed 's#/$##'`
GALAXY_DEPOT_URL=`echo $GALAXY_DEPOT_URL | sed -e 's#/$##'`

SUCCESS=0
for URL in ${URLS[@]}; do
  URL=`echo $URL | tr -d \"`  # Trim any flanking quotes
  URL=`echo $URL | sed -e "s#^BIOCONDUCTOR#$BIOCONDUCTOR_URL# ; s#^GALAXY_BIOARCHIVE#$GALAXY_BIOARCHIVE_URL# ; s#^GALAXY_DEPOT#$GALAXY_DEPOT#"`
  MD5=`echo $MD5 | tr -d \"`  # Trim any flanking quotes
  curl -L $URL > $TARBALL
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
  echo "If you are behind a proxy and have a mirror available you can use it by setting one of the environment variables: BIOCONDUCTOR_MIRROR, GALAXY_BIOARCHIVE_MIRROR or GALAXY_DEPOT_MIRROR"
  exit 1
fi

# Install and clean up
R CMD INSTALL --library=$PREFIX/lib/R/library $TARBALL
rm $TARBALL
rmdir $STAGING
