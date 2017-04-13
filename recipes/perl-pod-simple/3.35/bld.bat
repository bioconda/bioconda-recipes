:: If it has Build.PL use that, otherwise use Makefile.PL
IF exist Build.PL (
    perl Build.PL
    IF errorlevel 1 exit 1
    Build
    IF errorlevel 1 exit 1
    Build test
    :: Make sure this goes in site
    Build install --installdirs site
    IF errorlevel 1 exit 1
) ELSE IF exist Makefile.PL (
    :: Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    IF errorlevel 1 exit 1
    make
    IF errorlevel 1 exit 1
    make test
    IF errorlevel 1 exit 1
    make install
) ELSE (
    ECHO 'Unable to find Build.PL or Makefile.PL. You need to modify bld.bat.'
    exit 1
)

:: Add more build steps here, if they are necessary.

:: See
:: http://docs.continuum.io/conda/build.html
:: for a list of environment variables that are set during the build process.
