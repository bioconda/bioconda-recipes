#
# BioPerl module for Bio::SeqIO::FTHelper
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::FTHelper - Helper class for EMBL/Genbank feature tables

=head1 SYNOPSIS

Used by Bio::SeqIO::EMBL,Bio::SeqIO::genbank, and Bio::SeqIO::swiss to
help process the Feature Table

=head1 DESCRIPTION

Represents one particular Feature with the following fields

      key - the key of the feature
      loc - the location string of the feature
      <other fields> - other fields

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
the bugs and their resolution.  Bug reports can be submitted via the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

=head1 CONTRIBUTORS

Jason Stajich jason@bioperl.org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::SeqIO::FTHelper;
use strict;

use Bio::SeqFeature::Generic;
use Bio::Location::Simple;
use Bio::Location::Fuzzy;
use Bio::Location::Split;

use base qw(Bio::Root::Root);

sub new {
    my ($class, @args) = @_;

    # no chained new because we make lots and lots of these.
    my $self = {};
    bless $self,$class;
    $self->{'_field'} = {};
    return $self;
}

=head2 _generic_seqfeature

 Title   : _generic_seqfeature
 Usage   : $fthelper->_generic_seqfeature($annseq, "GenBank")
 Function: processes fthelper into a generic seqfeature
 Returns : TRUE on success and otherwise FALSE
 Args    : The Bio::Factory::LocationFactoryI object to use for parsing
           location strings. The ID (e.g., display_id) of the sequence on which
           this feature is located, optionally a string indicating the source
           (GenBank/EMBL/SwissProt)

=cut

sub _generic_seqfeature {
    my ($fth, $locfac, $seqid, $source) = @_;
    my ($sf);

    # set a default if not specified
    if(! defined($source)) {
	$source = "EMBL/GenBank/SwissProt";
    }

    # initialize feature object
    $sf = Bio::SeqFeature::Generic->direct_new();

    # parse location; this may cause an exception, in which case we gently
    # recover and ignore this feature


    my $loc;
    eval {
	$loc = $locfac->from_string($fth->loc);
    };

    if(! $loc) {
	  $fth->warn("exception while parsing location line [" . $fth->loc .
		      "] in reading $source, ignoring feature " .
		      $fth->key() . " (seqid=" . $seqid . "): " . $@);
	  return;
    }

    # set additional location attributes
    if($seqid && (! $loc->is_remote())) {
	$loc->seq_id($seqid); # propagates if it is a split location
    }


    # set attributes of feature
    $sf->location($loc);
    $sf->primary_tag($fth->key);
    $sf->source_tag($source);
    $sf->seq_id($seqid);
    foreach my $key ( keys %{$fth->field} ){
	foreach my $value ( @{$fth->field->{$key}} ) {
	    $sf->add_tag_value($key,$value);
	}
    }
    return $sf;
}


=head2 from_SeqFeature

 Title   : from_SeqFeature
 Usage   : @fthelperlist = Bio::SeqIO::FTHelper::from_SeqFeature($sf,
						     $context_annseq);
 Function: constructor of fthelpers from SeqFeatures
         :
         : The additional annseq argument is to allow the building of FTHelper
         : lines relevant to particular sequences (ie, when features are spread over
         : enteries, knowing how to build this)
 Returns : an array of FThelpers
 Args    : seq features


=cut

sub from_SeqFeature {
  my ($sf, $context_annseq) = @_;
  my @ret;

  #
  # If this object knows how to make FThelpers, then let it
  # - this allows us to store *really* weird objects that can write
  # themselves to the EMBL/GenBank...
  #

  if ( $sf->can("to_FTHelper") ) {
	return $sf->to_FTHelper($context_annseq);
  }

  my $fth = Bio::SeqIO::FTHelper->new();
  my $key = $sf->primary_tag();
  my $locstr = $sf->location->to_FTstring;

  # ES 25/06/01 Commented out this code, Jason to double check
  #The location FT string for all simple subseqfeatures is already
  #in the Split location FT string

  # going into sub features
  #foreach my $sub ( $sf->sub_SeqFeature() ) {
  #my @subfth = &Bio::SeqIO::FTHelper::from_SeqFeature($sub);
  #push(@ret, @subfth);
  #}

  $fth->loc($locstr);
  $fth->key($key);
  $fth->field->{'note'} = [];
  
  # the lines below take specific tags (e.g. /score=23 ) and re-enter them as
  # new tags like /note="score=25" - if the file is round-tripped this creates
  # duplicate values

  #$sf->source_tag && do { push(@{$fth->field->{'note'}},"source=" . $sf->source_tag ); };

  #($sf->can('score') && $sf->score) && do { push(@{$fth->field->{'note'}},
  #                                               "score=" . $sf->score ); };
  
  #($sf->can('frame') && $sf->frame) && do { push(@{$fth->field->{'note'}},
  #                                               "frame=" . $sf->frame ); };
  
  #$sf->strand && do { push(@{$fth->field->{'note'}},"strand=" . $sf->strand ); };

  foreach my $tag ( $sf->get_all_tags ) {
    # Tags which begin with underscores are considered
    # private, and are therefore not printed
    next if $tag =~ /^_/;
	if ( !defined $fth->field->{$tag} ) {
      $fth->field->{$tag} = [];
	}
	foreach my $val ( $sf->get_tag_values($tag) ) {
      push(@{$fth->field->{$tag}},$val);
	}
  }
  push(@ret, $fth);

  unless (@ret) {
	$context_annseq->throw("Problem in processing seqfeature $sf - no fthelpers. Error!");
  }
  foreach my $ft (@ret) {
	if ( !$ft->isa('Bio::SeqIO::FTHelper') ) {
      $sf->throw("Problem in processing seqfeature $sf - made a $fth!");
	}
  }

  return @ret;
}


=head2 key

 Title   : key
 Usage   : $obj->key($newval)
 Function:
 Example :
 Returns : value of key
 Args    : newvalue (optional)


=cut

sub key {
   my ($obj, $value) = @_;
   if ( defined $value ) {
      $obj->{'key'} = $value;
    }
    return $obj->{'key'};

}

=head2 loc

 Title   : loc
 Usage   : $obj->loc($newval)
 Function:
 Example :
 Returns : value of loc
 Args    : newvalue (optional)


=cut

sub loc {
   my ($obj, $value) = @_;
   if ( defined $value ) {
      $obj->{'loc'} = $value;
    }
    return $obj->{'loc'};
}


=head2 field

 Title   : field
 Usage   :
 Function:
 Example :
 Returns :
 Args    :


=cut

sub field {
   my ($self) = @_;

   return $self->{'_field'};
}

=head2 add_field

 Title   : add_field
 Usage   :
 Function:
 Example :
 Returns :
 Args    :


=cut

sub add_field {
   my ($self, $key, $val) = @_;

   if ( !exists $self->field->{$key} ) {
       $self->field->{$key} = [];
   }
   push( @{$self->field->{$key}} , $val);

}

1;
