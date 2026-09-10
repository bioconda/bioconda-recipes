#!/bin/bash

export DISABLE_AUTOBREW=1

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* src/graphviz/config/
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* ./

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

mkdir -p ~/.R

#echo -e "CC=$CC
#FC=$FC
#CC17=$CC -std=gnu11
#CXX=$CXX
#CXX98=$CXX
#CXX11=$CXX
#CXX14=$CXX" > ~/.R/Makevars

# conda r-base ships CC17 empty on osx-arm64; Rgraphviz needs USE_C17.
# R injects CC='$(CC17)' / CFLAGS='$(C17FLAGS)' at install time, so these must be
# LITERAL -- referencing $(CC)/$(CFLAGS) makes 'make' recurse.
RCC="$(${R} CMD config CC)"
RCFLAGS="$(${R} CMD config CFLAGS)"
export R_MAKEVARS_USER="${SRC_DIR}/Makevars.c17"
cat > "${R_MAKEVARS_USER}" <<EOF
CC17 = ${RCC} -std=gnu17
C17FLAGS = ${RCFLAGS}
EOF

autoreconf -if

$R CMD INSTALL --build . ${R_ARGS}
