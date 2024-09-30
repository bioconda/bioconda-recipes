#!/bin/bash

# increase verbosity for debugging
set -x

mkdir -p $PREFIX/bin

# Replace `mawk -f` shebangs with "polyglot shebangs"
# as per https://unix.stackexchange.com/a/361796/605705
# not to rely on non-standard `env -S` option
polyglot1='#!/bin/sh'; polyglot2='"exec" "mawk" "-f" "$0" "$@" && 0 {}'
for f in $SRC_DIR/scripts/*; do 
  t="$PREFIX/bin/$(basename $f)"
  head -n 1 $f | grep awk && ( echo "$polyglot1" > $t && echo "$polyglot2" >> $t )
  cat $f >> $t
done

chmod +x $PREFIX/bin/*

