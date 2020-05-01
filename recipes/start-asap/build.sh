#!/bin/bash
set -euxo pipefail
pwd
ls -l  
mkdir -p ${PREFIX}/bin
chmod +x ./start-asap

mv ./start-asap  ${PREFIX}/bin/


