#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
export _JAVA_OPTIONS="-Xss2560k"
$R CMD javareconf
$R CMD INSTALL --build .
