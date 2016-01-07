#!/bin/sh
sed -i.bak 's#/usr/local#$PREFIX#' Makefile
make
make install
