#!/bin/bash

sed '158 i echo "RET=${RET}"' configure.sh

./configure.sh -j ${JAVA_HOME}
make
