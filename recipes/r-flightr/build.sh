#!/bin/bash

echo  'require("devtools")\ninstall_github("eldarrak/FLightR") ' > $R CMD INSTALL --build .

