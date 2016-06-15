:: If it has Build.PL use that, otherwise use Makefile.PL
:: Make sure this goes in site

:: This may not work due to the zlib dependency.
perl Makefile.PL INSTALLDIRS=site
IF errorlevel 1 exit 1

make
IF errorlevel 1 exit 1

make test
IF errorlevel 1 exit 1

make install
