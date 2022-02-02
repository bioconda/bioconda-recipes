#!/bin/bash

# downloading large (4GB) required dataset

FN="mapref-2.2b.tar.gz"
URLS=(
  "http://www.microbeatlas.org/mapref/mapref-2.2b.tar.gz"
)
MD5="9ea29a1a4ec9293aa78fc660841121c8"


STAGING=$PREFIX/share/mapseq
#STAGING=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $STAGING
TARBALL=$STAGING/$FN

# debugging info
#ls -lahrt $STAGING
#ldd $PREFIX/bin/mapseq

SUCCESS=0
for URL in ${URLS[@]}; do
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

tar -C $STAGING -xvzf $TARBALL # >> $PREFIX/.messages.txt
#echo "Staging directory: $STAGING" >> $PREFIX/.messages.txt
#ls -lahrt $STAGING >> $PREFIX/.messages.txt
#ls -lahrt $STAGING/mapref-2.2b >> $PREFIX/.messages.txt
mv $STAGING/mapref-2.2b/* $STAGING/
rmdir $STAGING/mapref-2.2b
rm $TARBALL


#echo "Staging directory2: $STAGING" >> $PREFIX/.messages.txt
#ls -lahrt $STAGING >> $PREFIX/.messages.txt
#echo "mapref:" >> $PREFIX/.messages.txt
#head -n 2 $STAGING/mapref-2.2b.fna >> $PREFIX/.messages.txt
#echo `which mapseq` >> $PREFIX/.messages.txt
#strings `which mapseq` | grep 'share/' >> $PREFIX/.messages.txt
#ls -lahrt $STAGING/mapref-2.2b.fna >> $PREFIX/.messages.txt



# WARNING: cannot run test because CircleCI probably has memory/cpu limits

# testing to ensure dataset is correctly installed and found by mapseq
#head -n 2 $STAGING/mapref-2.2b.fna | mapseq - > $STAGING/test.fna.mseq 2>> $PREFIX/.messages.txt || ( echo "ERROR running mapseq"; exit -1 )
#head -n 2 $STAGING/mapref-2.2b.fna | mapseq - > $STAGING/test.fna.mseq || ( echo "ERROR running mapseq"; exit -1 )
#test "$(wc -l < test.fna.mseq)" -eq 3 || ( rm $STAGING/test.fna.mseq; echo "ERROR running mapseq: unexpected output"; exit -1 )
#echo "Results: $STAGING" >> $PREFIX/.messages.txt
#cat $STAGING/test.fna.mseq >> $PREFIX/.messages.txt
#rm $STAGING/test.fna.mseq

