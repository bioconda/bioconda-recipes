#!/bin/bash

mkdir HLA-LA HLA-LA/bin HLA-LA/src HLA-LA/obj HLA-LA/temp HLA-LA/working HLA-LA/graphs
mv * HLA-LA/src
cd src

make all

