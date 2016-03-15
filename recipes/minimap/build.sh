  #!/bin/bash

  #strictly use anaconda build environment
  CC=${PREFIX}/bin/gcc
  CXX=${PREFIX}/bin/g++

  mkdir -p $PREFIX/bin

  make 
  make extra 

  cp minimap $PREFIX/bin 
  cp minimap-lite $PREFIX/bin
  cp sdust $PREFIX/bin
  
