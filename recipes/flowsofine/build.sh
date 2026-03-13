#!/bin/bash
echo 'library("devtools");' > install.r
echo 'devtools::install_git("FlowSoFine", upgrade="never");' > install.r
echo 'devtools::install_git("FlowSoFineApp", upgrade="never");' > install.r

cat install.r | R --vanilla
