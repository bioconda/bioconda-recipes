#!/bin/bash
cd "$PREFIX"
TARBALL="mykrobe-data.tar.gz"
URLS=(
  "https://bit.ly/2H9HKTU"
)
MD5="cce48d0e0a5bc93916007b576bf6ace4"

SUCCESS=0
for URL in ${URLS[@]}; do
  wget -O- ${URL} > "$TARBALL"
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
  echo "ERROR: post-link.sh was unable to download any of the following URLs with the md5sum $MD5:" >> "${PREFIX}/.messages.txt" 2>&1
  printf '%s\n' "${URLS[@]}" >> "${PREFIX}/.messages.txt" 2>&1
  exit 1

tar -vxzf "$TARBALL"
rm -fr "$PREFIX"/src/mykrobe/data
mv mykrobe-data "$PREFIX"/src/mykrobe/data
rm "$TARBALL"
