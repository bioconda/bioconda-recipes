#!/bin/bash

if [[ $PY3K == "1" ]] ; then 
  cp python3/* $PREFIX/bin
else
  cp python/* $PREFIX/bin
fi
