:: If it has Build.PL use that, otherwise use Makefile.PL
IF exist Build.PL (
    perl Build.PL
    IF errorlevel 1 exit 1
    Build
    IF errorlevel 1 exit 1
    :: Build test # expected to fail as we don't had perl-heap-simple as dep to avoid cyclic dependency
    :: Make sure this goes in site
    Build install --installdirs site
    IF errorlevel 1 exit 1
) ELSE IF exist Makefile.PL (
    :: Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    IF errorlevel 1 exit 1
    make
    IF errorlevel 1 exit 1
    :: make test # expected to fail as we don't had perl-heap-simple as dep to avoid cyclic dependency
    IF errorlevel 1 exit 1
    make install
) ELSE (
    ECHO 'Unable to find Build.PL or Makefile.PL. You need to modify bld.bat.'
    exit 1
)
