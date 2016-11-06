#!/bin/sh

#During 'make', in the shebang lines of the perl scripts,
#conda-forge inserts a placeholder line which is over 250 characters.
#This causes the problem for running the perl scripts while making the package.
#It seems there is a length restriction on the shebang line,
#which is about 70 characters max.
#Therefore the long placeholder is automatically truncated
#that results in the failure for locating perl.
#The workaround solution is creating a soft link to perl in the building dir.
#Then replace the long path to perl with the short path to the link.
#After 'make install', change the path of the link back to the real path.

#get the path to perl
perl_inteprator=$(./configure --prefix=$PREFIX | grep 'checking for perl...' | sed 's|checking for perl... ||g')


#create soft link and place its path in bin/Make
ln -s $perl_inteprator temp_perl
temp_link=$(pwd)/temp_perl
sed -i "s|"$perl_inteprator"|"$temp_link"|g" bin/Makefile

make
make install

#change the link path back to the real path
sed -i "s|"$temp_link"|"$perl_inteprator"|g" $PREFIX/bin/autom4te
sed -i "s|"$temp_link"|"$perl_inteprator"|g" $PREFIX/bin/autoheader
sed -i "s|"$temp_link"|"$perl_inteprator"|g" $PREFIX/bin/autoreconf
sed -i "s|"$temp_link"|"$perl_inteprator"|g" $PREFIX/bin/ifnames
sed -i "s|"$temp_link"|"$perl_inteprator"|g" $PREFIX/bin/autoscan
sed -i "s|"$temp_link"|"$perl_inteprator"|g" $PREFIX/bin/autoupdate
