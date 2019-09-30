### Triggering compilation
cd linux/VirFinder/
echo "NeedsCompilation: yes" >> DESCRIPTION


### Building
$R CMD INSTALL --build .
