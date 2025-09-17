#!/usr/bin/env bash

#Creating the bin directory
mkdir -p "$PREFIX/bin"

#Making CATS-rb scripts executable
chmod +x scripts/*

#Copying CATS-rb scripts to the bin folder
cp scripts/* "$PREFIX/bin"
