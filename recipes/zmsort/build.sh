#!/bin/bash
sed -i "s,../gclib,${PREFIX}/lib," Makefile
make
