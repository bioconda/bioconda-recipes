#!/bin/bash

export DISABLE_AUTOBREW=1
export LC_ALL=C

# Remove forced C++11 so R's default standard (C++17) is used
for f in src/Makevars src/Makevars.win; do
   [ -f "$f" ] && sed -i.bak -E '/^[[:space:]]*CXX_STD[[:space:]]*=[[:space:]]*CXX11/d' "$f"
done
# Drop a C++11-only SystemRequirements line if present
sed -i.bak -E '/^SystemRequirements:[[:space:]]*C\+\+11[[:space:]]*$/d' DESCRIPTION

rm -f *.bak
rm -f src/*.bak

${R} CMD INSTALL --build . "${R_ARGS}"
