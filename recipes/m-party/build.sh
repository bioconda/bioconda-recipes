#!/bin/bash

BIN_FOLDER="$PREFIX/bin"
mkdir -p $BIN_FOLDER/workflow

cp -rf workflow/* $BIN_FOLDER/workflow/
cp -rf config $BIN_FOLDER/
cp -rf m-party.py "$BIN_FOLDER"

cp -rf workflow/scripts/*.py "$BIN_FOLDER"
cp -rf workflow/envs/*.yaml "$BIN_FOLDER"
cp -rf config/*.yaml "$BIN_FOLDER"
cp -rf workflow/Snakefile "$BIN_FOLDER"
cp -rf workflow/pathing_utils/*.py "$BIN_FOLDER"

echo "print bin folder"
ls -la $BIN_FOLDER

echo "print workflow folder"
ls -la $BIN_FOLDER/workflow

echo "print config folder"
ls -la $BIN_FOLDER/config

chmod 755 $BIN_FOLDER/m-party.py
ln -sf $BIN_FOLDER/m-party.py $BIN_FOLDER/m-party
