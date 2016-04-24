REPEATMASKER_DIR=${PREFIX}/share/RepeatMasker

perl -i -0pe \'s/^#\\!.*perl.*/#\\!\/usr\/bin\/perl/g;' RepeatMasker
perl -i -0pe \'s/^#\\!.*perl.*/#\\!\/usr\/bin\/perl/g;' DateRepeats
perl -i -0pe \'s/^#\\!.*perl.*/#\\!\/usr\/bin\/perl/g;' ProcessRepeats
perl -i -0pe \'s/^#\\!.*perl.*/#\\!\/usr\/bin\/perl/g;' RepeatProteinMask
perl -i -0pe \'s/^#\\!.*perl.*/#\\!\/usr\/bin\/perl/g;' DupMasker
perl -i -0pe \'s/^#\\!.*perl.*/#\\!\/usr\/bin\/perl/g;' util/queryRepeatDatabase.pl
perl -i -0pe \'s/^#\\!.*perl.*/#\\!\/usr\/bin\/perl/g;' util/queryTaxonomyDatabase.pl
perl -i -0pe \'s/^#\\!.*perl.*/#\\!\/usr\/bin\/perl/g;' util/rmOutToGFF3.pl
perl -i -0pe \'s/^#\\!.*perl.*/#\\!\/usr\/bin\/perl/g;' util/rmToUCSCTables.pl
cp RepeatMaskerConfig.pm /opt/RepeatMasker/RepeatMaskerConfig.pm
makeblastdb -dbtype nucl -in ${PREIFRepeatMasker/Libraries/RepeatMasker.lib
makeblastdb -dbtype prot -in /opt/RepeatMasker/Libraries/RepeatPeps.lib

