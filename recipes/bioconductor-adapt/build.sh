#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R
echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX
STRIP=$STRIP" > ~/.R/Makevars

# Fix ADAPT's Makevars: replace /usr/bin/strip (Xcode shim) with conda strip,
# and --strip-debug (Linux-only flag) with -S (macOS equivalent)
if [ -f src/Makevars ]; then
  sed -i.bak 's|/usr/bin/strip --strip-debug|$(STRIP) -S|g' src/Makevars
fi
if [ -f src/Makevars.win ]; then
  sed -i.bak 's|/usr/bin/strip --strip-debug|$(STRIP) --strip-debug|g' src/Makevars.win
fi

$R CMD INSTALL --build .
