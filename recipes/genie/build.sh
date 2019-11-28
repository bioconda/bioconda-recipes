#!/bin/bash

go build
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
