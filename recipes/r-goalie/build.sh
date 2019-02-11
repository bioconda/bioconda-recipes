# These lines to replace ...elt() calls with the one from backports  
#sed -i.bak "s/\.\.\.elt/backports::...elt/g" R/validate.R 
#sed -i.bak "s/\.\.\.elt/backports::...elt/g" R/assert.R 

$R CMD INSTALL --build .
