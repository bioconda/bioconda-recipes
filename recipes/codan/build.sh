#!/bin/bash

mkdir -p $PREFIX/bin
chmod +x bin/*
cp bin/* $PREFIX/bin

if ["$uname" == "Darwin"]; then
  unzip for_MacOS_users.zip
  chmod +x for_MacOS_users/*
  cp for_MacOS_users/tops-viterbi_decoding $PREFIX/bin
fi
