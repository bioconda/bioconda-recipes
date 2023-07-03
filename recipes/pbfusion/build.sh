#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
gunzip *.gz
mv pbfusion* pbfusion
chmod +x pbfusion
cp pbfusion "${PREFIX}"/bin/

