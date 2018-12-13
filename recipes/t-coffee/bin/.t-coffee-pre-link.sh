echo "** WARNING: This T-Coffee recipe is still under development **"
echo ""
echo "It does not contain all required packages to use all T-Coffee modes."
echo "We suggest to use the Bioconda 't_coffee' recipe instead or download it"
echo "from the web site http://www.tcoffee.org"
echo ""
read -u 1 -p "* Please confirm you want to continue with the installation [y/n] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi