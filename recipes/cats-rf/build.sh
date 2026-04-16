#!/usr/bin/env bash

#Creating the bin directory
mkdir -p "$PREFIX/bin"

#Making CATS-rf scripts executable
chmod +x scripts/*

#Copying CATS-rf scripts to the bin folder
cp scripts/* "$PREFIX/bin"
