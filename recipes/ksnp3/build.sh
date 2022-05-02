#!/bin/bash
mkdir -p ${PREFIX}/bin

chmod 775 ./kSNP3/*
rm ./kSNP4/.DS_Store
cp ./kSNP3/* ${PREFIX}/bin
