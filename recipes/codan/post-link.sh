#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  cp $PREFIX/for_MacOS_users/* $PREFIX/bin
fi
