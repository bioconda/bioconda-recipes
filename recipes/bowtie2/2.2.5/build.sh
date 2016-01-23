#!/bin/sh
make
mv ./* $PREFIX
chmod +x $PREFIX/*
