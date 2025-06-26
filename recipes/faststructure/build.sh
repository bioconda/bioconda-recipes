# Build vars
cd vars
python setup.py build_ext --inplace
cd ..

# Build main
python setup.py build_ext --inplace
cp vars/*.so ./

# Make scripts executable
chmod +x structure.py
chmod +x distruct.py
chmod +x chooseK.py

# Install files
mkdir -p ${PREFIX}/bin/vars
install -v -m 755 *.py ${PREFIX}/bin
install -v -m 755 *.so ${PREFIX}/bin
install -v -m 755 vars/*.py ${PREFIX}/bin/vars
install -v -m 755 vars/*.so ${PREFIX}/bin/vars
