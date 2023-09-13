### Triggering compilation
cd linux/VirFinder/
echo "NeedsCompilation: yes" >> DESCRIPTION
rm -f src/*.o src/*.so


### Building
$R CMD INSTALL --build .
