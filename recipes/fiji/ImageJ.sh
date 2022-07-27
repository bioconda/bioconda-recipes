#!/bin/bash
dir=$(dirname $(which ImageJ_bin))
echo ".                                                    
jre/bin/java
-Djava.util.prefs.userRoot=${dir}/../uprefs/ -cp ij.jar ij.ImageJ
" > ${dir}/../share/ImageJ.cfg
ImageJ_bin "$@"
