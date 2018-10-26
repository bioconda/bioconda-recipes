mkdir -p bin
perl -CD -pi -e'tr/\x{feff}//d && s/[\r\n]+/\n/' *.py 
mv *.py ${PREFIX}/bin/
