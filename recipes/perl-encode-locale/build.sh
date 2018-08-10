#!/bin/bash

if [ `uname` == Darwin ]; then
  export HOME=/tmp
fi

cpanm -i .
