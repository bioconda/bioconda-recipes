#!/bin/bash
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/etc/Brockman
cp ./brockman_pipeline $PREFIX/bin/. 
cp -r ./Resources $PREFIX/etc/Brockman/Resources
