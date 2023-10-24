#!/bin/bash

chmod +x glnexus_cli
mkdir -p ${PREFIX}/bin
cp -f glnexus_cli ${PREFIX}/bin

# #### Work in progress to build from source
# Building from source requires an updated version of capnproto 
# which is currently unavailable on conda-forge.  
