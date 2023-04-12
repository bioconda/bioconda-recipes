#!/usr/bin/env bash

mkdir -p "${PREFIX}"/bin
gunzip *.gz
mv gffcache* gffcache
mv pbfusion* pbfusion
chmod +x gffcache
chmod +x pbfusion
cp gffcache "${PREFIX}"/bin/
cp pbfusion "${PREFIX}"/bin/

