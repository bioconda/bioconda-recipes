#!/bin/bash
set -ex
# takes a single parameter, the package name

# FOR DEBUGGING
PREFIX=/home/espenr/temp
mkdir -p $PREFIX/lib/R/library
SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

#SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )/../share/bioconductor-data-packages"
json="${SCRIPT_DIR}/dataURLs.json"
FN=`yq ".\"$1\".fn" "${json}"`
FN=`echo $FN | tr -d \"`  # Strip quotes from filename
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

# Prepare caching
CACHE_DIR=$PREFIX/cache/"$1" # need to be set to something sensible that persists
mkdir -p $CACHE_DIR
CACHED_TARBALL="$CACHE_DIR/$FN"

# Prepend CACHED_TARBALL to URLS if it exists
if [[ -f "$CACHED_TARBALL" ]]; then
  URLS=("file://$CACHED_TARBALL" "${URLS[@]}")
fi

SUCCESS=0
for URL in ${URLS[@]}; do
  URL=`echo $URL | tr -d \"`  # Trim any flanking quotes
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
  exit 1
fi

# Install and clean up
R CMD INSTALL --library=$PREFIX/lib/R/library $TARBALL
mv $TARBALL $CACHE_DIR
rmdir $STAGING
