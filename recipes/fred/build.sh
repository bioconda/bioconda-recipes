#Patch away the install requires, we're getting these through conda directly
sed -i 's/install_requires/#install_requires/g' setup.py 
$PYTHON setup.py install