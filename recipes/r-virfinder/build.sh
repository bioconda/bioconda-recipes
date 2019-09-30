### Triggering compilation
echo "NeedsCompilation: yes" >> DESCRIPTION


### Building
$R CMD INSTALL --build .
