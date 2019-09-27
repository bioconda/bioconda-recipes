ls -a
cd linux/
tar -xzf VirFinder_1.1.tar.gz
cd VirFinder/
echo "NeedsCompilation: yes" >> DESCRIPTION

$R CMD INSTALL --build .