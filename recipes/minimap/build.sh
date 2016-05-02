  #!/bin/bash

  mkdir -p $PREFIX/bin

  make 
  make extra 

  cp minimap $PREFIX/bin 
  cp minimap-lite $PREFIX/bin
  cp sdust $PREFIX/bin
  
