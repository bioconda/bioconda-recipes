#!/bin/bash -euo

unamestr=`uname`

if [ "$unamestr" == 'Darwin' ];
then
  export CPPFLAGS=$(echo "${CPPFLAGS}" | sed 's|10\.9|10.15|g')
  export CMAKE_ARGS=$(echo "${CMAKE_ARGS}" | sed 's|10\.9|10.15|g')
fi
