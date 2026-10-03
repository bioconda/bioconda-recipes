#!/bin/bash

if [[ $target_platform =~ linux.* ]]; then 
    source="Linux/64bit/MaRaCluster/maracluster"
elif [[ $target_platform == osx-64 ]]; then
    source="MacOS/64bit/MaRaCluster/maracluster"
else
    >&2 echo "Only Linux and OSx are supported at the moment"
    exit 1
fi

mkdir -p "$PREFIX/bin/"
cp "$source" "$PREFIX/bin/"
