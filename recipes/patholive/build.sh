#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/etc
cp PathoLive.py ${PREFIX}/etc/
cp -r prelim_data ${PREFIX}/etc/
ln -s ${PREFIX}/etc/PathoLive.py ${PREFIX}/bin/PathoLive.py
ln -s ${PREFIX}/etc/PathoLive.py ${PREFIX}/bin/patholive

