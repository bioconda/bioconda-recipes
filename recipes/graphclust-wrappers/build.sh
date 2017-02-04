#!/bin/bash

#Copy binery file since there is no INSTALL part in the makefile
chmod +x galaxy_wrappers/*/*.pl
cp galaxy_wrappers/*/*.pl $PREFIX/bin/

