#!/bin/bash

# ld on ppc64le is sensitive to the order in which "-l<lib>" arguments are
# presented, so we have to munge the generated Makefile a little so libtidyp.so
# is properly linked when creating "Tidy.so".
cat >fix-link-order.patch <<'EOF'
--- Makefile
+++ Makefile
@@ -482,7 +482,7 @@

 $(INST_DYNAMIC): $(OBJECT) $(MYEXTLIB) $(INST_ARCHAUTODIR)$(DFSEP).exists $(EXPORT_LIST) $(PERL_ARCHIVEDEP) $(PERL_ARCHIVE_AFTER) $(INST_DYNAMIC_DEP)
 	$(RM_F) $@
-	$(LD)  $(LDDLFLAGS) $(LDFROM) $(OTHERLDFLAGS) -o $@ $(MYEXTLIB)	\
+	$(LD) $(LDFROM) $(LDDLFLAGS) $(OTHERLDFLAGS) -o $@ $(MYEXTLIB)	\
 	  $(PERL_ARCHIVE) $(LDLOADLIBS) $(PERL_ARCHIVE_AFTER) $(EXPORT_LIST)	\
 	  $(INST_DYNAMIC_FIX)
 	$(CHMOD) $(PERM_RWX) $@
EOF

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    ./Build
    ./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site \
        INC="-I${PREFIX}/include/tidyp" LIBS="-L${PREFIX}/lib"
    if [ `uname -m` == "ppc64le" ]; then
        patch -p0 < fix-link-order.patch
    fi
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

chmod u+rwx $PREFIX/bin/*
