#!/bin/bash

go build -o genie
mkdir -p $PREFIX/bin
cp genie $PREFIX/bin
