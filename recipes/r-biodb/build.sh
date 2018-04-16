#!/bin/bash
#export HOME=$(pwd)
#mkdir "$HOME/.R"
#cat >$HOME/.R/Makevars <<EOF
#CXX=clang++
#EOF
$R CMD INSTALL --build .
