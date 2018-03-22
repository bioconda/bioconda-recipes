#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/etc/Brockman
cp Brockman/brockman_pipeline $PREFIX/bin/. 
cp -r Brockman/Resources $PREFIX/etc/Brockman/Resources
