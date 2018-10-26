mkdir -p bin
python PLEK_setup.py
perl -CD -pi -e'tr/\x{feff}//d && s/[\r\n]+/\n/' *.py 
mv *.py ${PREFIX}/bin/
mv svm* ${PREFIX}/bin/
