sed -i 's/CC=g++/CC=\$(CXX)/' src/Makefile
$R CMD INSTALL --build .
