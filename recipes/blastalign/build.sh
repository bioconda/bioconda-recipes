#!/bin/bash

mkdir -p $PREFIX/bin
cp BlastAlign* $PREFIX/bin

sed -i.bak 's|#! /usr/bin/perl|#!/usr/bin/env perl|' $PREFIX/bin/*
