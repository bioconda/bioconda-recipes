#!/bin/bash
mkdir -p ${PREFIX}/bin

# Copy files
chmod 775 kSNP${PKG_VERSION}_Linux_package/kSNP3/*
rm kSNP${PKG_VERSION}_Linux_package/kSNP3/.DS_Store
cp kSNP${PKG_VERSION}_Linux_package/kSNP3/* ${PREFIX}/bin
