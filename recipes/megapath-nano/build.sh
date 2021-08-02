#!/bin/bash

mkdir -pv $PREFIX/bin
cp -rv bin/* db_preparation docs Dockerfile README.md LICENSE $PREFIX/bin
