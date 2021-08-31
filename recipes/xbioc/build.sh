#!/bin/bash
sed -i.bak '/^Priority: /d' DESCRIPTION
mkdir -p ~/.R
cat > ~/.R/Makevars <<EOF
CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX
EOF
$R CMD INSTALL --build .
