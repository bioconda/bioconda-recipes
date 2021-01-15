#!/bin/bash
echo "JAVA_HOMEllllll = ${JAVA_HOME}"
sed -i '158 i echo "RET=${RET}"' configure.sh
sed -i '159 i echo "JAVA_HOME=${JAVA_HOME}"' configure.sh

./configure.sh -j=${JAVA_HOME}
make
