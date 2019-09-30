### Triggering compilation
cd linux/VirFinder/
echo "NeedsCompilation: yes" >> DESCRIPTION
rm src/*.o src/*.so


### Building
$R CMD INSTALL --build .
