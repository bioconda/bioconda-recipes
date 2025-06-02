#!/bin/bash

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL
    perl ./Build
    perl ./Build test
    # Make sure this goes in site
    perl ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site
    make
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi

chmod +rx $PREFIX/bin/goa2rdf.pl
chmod +rx $PREFIX/bin/get_obsolete_terms.pl
chmod +rx $PREFIX/bin/get_ancestor_terms.pl
chmod +rx $PREFIX/bin/get_root_terms.pl
chmod +rx $PREFIX/bin/get_relationship_id_vs_relationship_namespace.pl
chmod +rx $PREFIX/bin/obo_intersection.pl
chmod +rx $PREFIX/bin/obo2apo.pl
chmod +rx $PREFIX/bin/get_subontology_from.pl
chmod +rx $PREFIX/bin/get_relationship_types.pl
chmod +rx $PREFIX/bin/obo2rdf.pl
chmod +rx $PREFIX/bin/get_obsolete_term_id_vs_def_in_go.pl
chmod +rx $PREFIX/bin/get_terms_and_synonyms.pl
chmod +rx $PREFIX/bin/go2csv.pl
chmod +rx $PREFIX/bin/get_child_terms.pl
chmod +rx $PREFIX/bin/obo_union.pl
chmod +rx $PREFIX/bin/get_term_synonyms.pl
chmod +rx $PREFIX/bin/get_descendent_terms.pl
chmod +rx $PREFIX/bin/get_parent_terms.pl
chmod +rx $PREFIX/bin/bioportal_csv2obo.pl
chmod +rx $PREFIX/bin/obo2owl.pl
chmod +rx $PREFIX/bin/get_term_id_vs_term_namespace.pl
chmod +rx $PREFIX/bin/get_relationship_id_vs_relationship_def.pl
chmod +rx $PREFIX/bin/get_terms_by_name.pl
chmod +rx $PREFIX/bin/get_lowest_common_ancestor.pl
chmod +rx $PREFIX/bin/obo_trimming.pl
chmod +rx $PREFIX/bin/get_term_local_neighbourhood.pl
chmod +rx $PREFIX/bin/get_relationship_id_vs_relationship_name.pl
chmod +rx $PREFIX/bin/owl2obo.pl
chmod +rx $PREFIX/bin/get_term_id_vs_term_def.pl
chmod +rx $PREFIX/bin/go2owl.pl
chmod +rx $PREFIX/bin/obo_transitive_reduction.pl
chmod +rx $PREFIX/bin/obo2tran.pl
chmod +rx $PREFIX/bin/get_terms.pl
chmod +rx $PREFIX/bin/obo2xml.pl
chmod +rx $PREFIX/bin/get_obsolete_term_id_vs_name_in_go.pl
chmod +rx $PREFIX/bin/get_term_id_vs_term_name.pl
