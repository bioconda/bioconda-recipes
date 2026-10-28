#!/bin/bash

export DISABLE_AUTOBREW=1

mv DESCRIPTION DESCRIPTION.old

grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

mkdir -p ~/.R

echo -e "CC=$CC
FC=$FC
CXX=$CXX -Wno-register
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars

# std::bind2nd was removed in C++17 and libc++ enforces it; rewrite as the equivalent std::bind
grep -rlE 'std::bind2nd\(' src | xargs sed -i.bak \
  's/std::bind2nd(\(std::[a-z_]*<[a-z]*>()\), *\([^)]*\))/std::bind(\1, std::placeholders::_1, \2)/g'
find src -name '*.cpp.bak' -delete

${R} CMD INSTALL --build . "${R_ARGS}"
