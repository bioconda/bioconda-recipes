#!/bin/bash

set -ex

mkdir -p "$PREFIX/"
cp -rv bin "$PREFIX"
cp -rv lib  "$PREFIX"

# for those the don't like capital letters in commands
ln -fs "$PREFIX"/bin/MZmine "$PREFIX"/bin/mzmine