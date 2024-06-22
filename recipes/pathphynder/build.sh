#!/bin/bash

sed -i '1 i\#!/usr/bin/env Rscript\n' pathPhynder.R

cp pathPhynder.R $PREFIX/bin/pathPhynder
