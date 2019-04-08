#!/bin/bash

# copy main scripts
chmod +x *.pl
chmod +x gmcloser
chmod +x gmvalue
cp *.pl ${PREFIX}/bin/
cp gmcloser ${PREFIX}/bin/
cp gmvalue ${PREFIX}/bin/

# copy utility scripts
chmod +x Utility_gmvalue/*
cp Utility_gmvalue/* ${PREFIX}/bin/
