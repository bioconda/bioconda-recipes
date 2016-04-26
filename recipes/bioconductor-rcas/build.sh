
#!/bin/bash

# R refuses to build packages that mark themselves as
# "Priority: Recommended"
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION

#While developing a bioconductor pacakge,
#bioconductor only allows using the development version of R
#which is 3.3.0 at the time of development.
#Aapart from the above reason,
#bioconductor-rcas has been tested and so allowed on R 3.2.2.
sed -e 's|Depends: R (>= 3.3.0)|Depends: R (>= 3.2.2)|' -i DESCRIPTION


$R CMD INSTALL --build .
#
# # Add more build steps here, if they are necessary.
#
# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build
# process.
#
