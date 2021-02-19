#!/bin/bash



FN="mapref-2.2b.tar.gz"
URLS=(
  "http://www.microbeatlas.org/mapref/mapref-2.2b.tar.gz"
)
MD5="9ea29a1a4ec9293aa78fc660841121c8"


STAGING=$PREFIX/share/mapseq
#STAGING=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
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

tar -xvzf $TARBALL
mv $STAGING/mapref-2.2b/* $STAGING/
rmdir $STAGING/mapref-2.2b
rm $TARBALL
#rmdir $STAGING

