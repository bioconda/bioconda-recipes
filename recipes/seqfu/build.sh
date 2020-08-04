#!/bin/bash
 
mkdir -p ${PREFIX}/bin
chmod +x ./bin/*
mv ./bin/* ${PREFIX}/bin/
mv seqfu ${PREFIX}/bin/
