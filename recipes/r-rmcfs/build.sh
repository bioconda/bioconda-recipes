#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD javareconf
$R CMD INSTALL --build .
