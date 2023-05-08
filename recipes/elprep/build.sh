#!/bin/bash

mkdir -p $PREFIX/bin/

export GOPATH=$PREFIX
go install
