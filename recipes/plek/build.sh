mkdir -p bin
perl -CD -pi -e'tr/\x{feff}//d && s/[\r\n]+/\n/' *.py 
ln -s ${PREFIX}/PLEK* ${PREFIX}/bin/ 
ln -s ${PREFIX} svm* ${PREFIX}/bin/ 
