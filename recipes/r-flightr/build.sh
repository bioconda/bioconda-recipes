#!/bin/bash

echo 'require("devtools")' > setup.R
echo 'install_github("eldarrak/FLightR")'  >> setup.R
cat setup.R | $R --no-save

