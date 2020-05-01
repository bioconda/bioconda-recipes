#!/bin/bash

echo -n "BUILDING:"
pwd
echo ""
ls -l  
echo ""
mkdir -p ${PREFIX}/bin
chmod +x ./start-asap
mv ./start-asap  ${PREFIX}/bin/
#mv ./start-asap ./asap-lib ${PREFIX}/bin/


mv ./start-asap ${PREFIX}/bin/
