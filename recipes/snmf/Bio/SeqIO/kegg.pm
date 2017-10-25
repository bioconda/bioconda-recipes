#
# BioPerl module for Bio::SeqIO::kegg
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Allen Day <allenday@ucla.edu>
#
# Copyright Allen Day
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::kegg - KEGG sequence input/output stream

=head1 SYNOPSIS

  # It is probably best not to use this object directly, but
  # rather go through the SeqIO handler system. Go:

  use Bio::SeqIO;

  $stream = Bio::SeqIO->new(-file => $filename, -format => 'KEGG');

  while ( my $seq = $stream->next_seq() ) {
	# do something with $seq
  }

=head1 DESCRIPTION

This class transforms KEGG gene records into Bio::Seq objects.

=head2 Mapping of record properties to object properties

This section is supposed to document which sections and properties of
a KEGG databank record end up where in the Bioperl object model. It
is far from complete and presently focuses only on those mappings
which may be non-obvious. $seq in the text refers to the
Bio::Seq::RichSeqI implementing object returned by the parser for each
record.

=over 4

=item 'ENTRY'

 $seq->primary_id

=item 'NAME'

 $seq->display_id

=item 'DEFINITION'

 $seq->annotation->get_Annotations('description');

=item 'ORTHOLOG'

 grep {$_->database eq 'KO'} $seq->annotation->get_Annotations('dblink')

=item 'CLASS'

 grep {$_->database eq 'PATH'}
          $seq->annotation->get_Annotations('dblink')

=item 'POSITION'

FIXME, NOT IMPLEMENTED

=item 'PATHWAY'

 for my $pathway ( $seq->annotation->get_Annotations('pathway') ) {
    #
 }

=item 'DBLINKS'

 $seq->annotation->get_Annotations('dblink')

=item 'CODON_USAGE'

FIXME, NOT IMPLEMENTED

=item 'AASEQ'

 $seq->translate->seq

=item 'NTSEQ'

 $seq-E<gt>seq

=back

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

  bioperl-l@bioperl.org                  - General discussion
  http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Support 

Please direct usage questions or support issues to the mailing list:

I<bioperl-l@bioperl.org>

rather than to the module maintainer directly. Many experienced and 
reponsive experts will be able look at the problem and quickly 
address it. Please include a thorough description of the problem 
with code and data examples if at all possible.

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution. Bug reports can be submitted via the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Allen Day

Email allenday@ucla.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::kegg;
use strict;

use Bio::SeqFeature::Generic;
use Bio::Species;
use Bio::Seq::SeqFactory;
use Bio::Annotation::Collection;
use Bio::Annotation::Comment;
use Bio::Annotation::DBLink;

use base qw(Bio::SeqIO);

sub _initialize {
	my($self,@args) = @_;

	$self->SUPER::_initialize(@args);
	# hash for functions for decoding keys.
	$self->{'_func_ftunit_hash'} = {};
	if( ! defined $self->sequence_factory ) {
		$self->sequence_factory(Bio::Seq::SeqFactory->new
										(-verbose => $self->verbose(),
										 -type => 'Bio::Seq::RichSeq'));
	}
}

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : Bio::Seq::RichSeq object
 Args    :

=cut

sub next_seq {
	my ($self,@args) = @_;
	my $builder = $self->sequence_builder();
	my $seq;
	my %params;

	my $buffer;
	my (@acc, @features);
	my ($display_id, $annotation);
	my $species;

	# initialize; we may come here because of starting over
	@features = ();
	$annotation = undef;
	@acc = ();
	$species = undef;
	%params = (-verbose => $self->verbose); # reset hash
	local($/) = "///\n";

	$buffer = $self->_readline();

	return if( !defined $buffer ); # end of file
	$buffer =~ /^ENTRY/ ||
	  $self->throw("KEGG stream with bad ENTRY line. Not KEGG in my book. Got $buffer'");

	my %FIELDS;
	my @chunks = split /\n(?=\S)/, $buffer;

	foreach my $chunk (@chunks){
		my($key) = $chunk =~ /^(\S+)/;
		$FIELDS{$key} = $chunk;
	}

	# changing to split method to get entry_ids that include
	# sequence version like Whatever.1
	my(undef,$entry_id,$entry_seqtype,$entry_species) =
	  split(' ',$FIELDS{ENTRY});

	my($name);
	if ($FIELDS{NAME}) {
          ($name) = $FIELDS{NAME} =~ /^NAME\s+(.+)$/;
	}

        my( $definition, $aa_length, $aa_seq, $nt_length, $nt_seq );

        if(( exists $FIELDS{DEFINITION} ) and ( $FIELDS{DEFINITION} =~ /^DEFINITION/ )) {
          ($definition) = $FIELDS{DEFINITION} =~ /^DEFINITION\s+(.+)$/s;
          $definition =~ s/\s+/ /gs;
        }
        if(( exists $FIELDS{AASEQ} ) and ( $FIELDS{AASEQ} =~ /^AASEQ/ )) {
          ($aa_length,$aa_seq) = $FIELDS{AASEQ} =~ /^AASEQ\s+(\d+)\n(.+)$/s;
          $aa_seq =~ s/\s+//g;
        }
        if(( exists  $FIELDS{NTSEQ} ) and ( $FIELDS{NTSEQ} =~ /^NTSEQ/ )) {
          ($nt_length,$nt_seq) = $FIELDS{NTSEQ} =~ /^NTSEQ\s+(\d+)\n(.+)$/s;
          $nt_seq =~ s/\s+//g;
        }

	$annotation = Bio::Annotation::Collection->new();

	$annotation->add_Annotation('description',
						Bio::Annotation::Comment->new(-text => $definition));

	$annotation->add_Annotation('aa_seq',
						Bio::Annotation::Comment->new(-text => $aa_seq));

	my($ortholog_db,$ortholog_id,$ortholog_desc);
	if ($FIELDS{ORTHOLOG}) {
		($ortholog_db,$ortholog_id,$ortholog_desc) = $FIELDS{ORTHOLOG}
		  =~ /^ORTHOLOG\s+(\S+):\s+(\S+)\s+(.*?)$/;

        $annotation->add_Annotation('dblink',Bio::Annotation::DBLink->new(
                     -database => $ortholog_db,
                     -primary_id => $ortholog_id,
                     -comment => $ortholog_desc) );
  }

  if($FIELDS{MOTIF}){
     $FIELDS{MOTIF} =~ s/^MOTIF\s+//;
     while($FIELDS{MOTIF} =~/\s*?(\S+):\s+(.+?)$/mg){
         my $db = $1;
         my $ids = $2;
         foreach my $id (split(/\s+/, $ids)){

     $annotation->add_Annotation('dblink',Bio::Annotation::DBLink->new(
              -database =>$db,
              -primary_id => $id,
              -comment => "")   );
        }
     }
  }

  if($FIELDS{PATHWAY}) {
     $FIELDS{PATHWAY} =~ s/^PATHWAY\s+//;
     while($FIELDS{PATHWAY} =~ /\s*PATH:\s+(.+)$/mg){
        $annotation->add_Annotation('pathway',
           Bio::Annotation::Comment->new(-text => "$1"));
     }
  }

  if($FIELDS{POSITION}) {
    $FIELDS{POSITION} =~ s/^POSITION\s+//;
    $annotation->add_Annotation('position',
      Bio::Annotation::Comment->new(-text => $FIELDS{POSITION}));
  }
  
  if ($FIELDS{CLASS}) {
      $FIELDS{CLASS} =~ s/^CLASS\s+//;
      $FIELDS{'CLASS'} =~ s/\n//g;
      while($FIELDS{CLASS} =~ /(.*?)\[(\S+):(\S+)\]/g){
          my ($pathway,$db,$id) = ($1,$2,$3);
          $pathway =~ s/\s+/ /g;
          $pathway =~ s/\s$//g;
          $pathway =~ s/^\s+//;
          $annotation->add_Annotation('pathway',
                  Bio::Annotation::Comment->new(-text => $pathway));

          $annotation->add_Annotation('dblink',Bio::Annotation::DBLink->new(
                      -database => $db, -primary_id => $id));
      }
  }

  if($FIELDS{DBLINKS}) {
      $FIELDS{DBLINKS} =~ s/^DBLINKS/       /;
      while($FIELDS{DBLINKS} =~ /\s+(\S+):\s+(\S+)\n?/gs){ ### modified
           $annotation->add_Annotation('dblink',Bio::Annotation::DBLink->new(
                    -database => $1, -primary_id => $2)) if $1;
      }
  }

  $params{'-alphabet'}         = 'dna';
  $params{'-seq'}              = $nt_seq;
  $params{'-display_id'}       = $name;
  $params{'-accession_number'} = $entry_id;
  $params{'-species'}          = Bio::Species->new(
											  -common_name => $entry_species);
  $params{'-annotation'}       = $annotation;

  $builder->add_slot_value(%params);
  $seq = $builder->make_object();

  return $seq;
}

=head2 write_seq

 Title   : write_seq
 Note    : write_seq() is not implemented for KEGG format output.

=cut

sub write_seq {
    shift->throw("write_seq() not implemented for KEGG format output.");
}

1;
