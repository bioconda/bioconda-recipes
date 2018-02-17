#!/bin/bash

mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

autoconf
$R CMD INSTALL --build .
