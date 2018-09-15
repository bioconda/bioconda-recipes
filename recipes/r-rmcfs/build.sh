#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R -e "options(java.parameters = '-Xss2560k')"
$R CMD javareconf
$R CMD INSTALL --build .
