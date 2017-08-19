# BioPerl module for Bio::SeqIO::tinyseqHandler
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Donald Jackson, donald.jackson@bms.com
#
# Copyright Bristol-Myers Squibb
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::tinyseq::tinyseqHandler - XML event handlers to support NCBI TinySeq XML parsing

=head1 SYNOPSIS

Do not use this module directly; use the SeqIO handler system:

  $stream = Bio::SeqIO->new( -file => $filename, -format => 'tinyseq' );

  while ( my $seq = $stream->next_seq ) {
    ....
  }

=head1 DESCRIPTION

This object provides event handler methods for parsing sequence files
in the NCBI TinySeq XML format.  A TinySeq is a lightweight XML file
of sequence information on one or more sequences, analgous to FASTA
format.

See L<http://www.ncbi.nlm.nih.gov/dtd/NCBI_TSeq.mod.dtd> for the DTD.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to
the Bioperl mailing list.  Your participation is much appreciated.

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
of the bugs and their resolution. Bug reports can be submitted via
the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 SEE ALSO

L<Bio::SeqIO>, L<Bio::Seq>.

=head1 AUTHOR

Donald Jackson, E<lt>donald.jackson@bms.comE<gt>

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

package Bio::SeqIO::tinyseq::tinyseqHandler;

use strict;
use warnings;


use vars qw(%ATTMAP);

use base qw(Bio::Root::Root);

# %ATTMAP defines correspondence between TSeq elements, PrimarySeq attributes
# Format: element_name => { xml_attname => pseq_attname }
%ATTMAP	= ( TSeq_sequence	=> { Data	=> '-seq'},
	    TSeq_gi		=> { Data	=> '-primary_id' },
	    TSeq_defline	=> { Data	=> '-desc' },
	    TSeq_sid		=> { Data	=> '-sid' },
	    TSeq_accver		=> { Data	=> '-accver' },
	    TSeq_taxid		=> { Data	=> '-taxid' },
	    TSeq_orgname	=> { Data	=> '-organism' }
	   );

=head2 new

  Title		: new
  Usage		: $handler = Bio::SeqIO::tinyseq::tinyseqHandler->new()
  Function	: instantiates a tinyseqHandler for use by
                  XML::Parser::PerlSAX
  Returns	: Bio::SeqIO::tinyseq::tinyseqHandler object
  Args		: NONE

=cut

sub new {
    my ($proto, @args) = @_;
    my $class = ref($proto) || $proto;

    my $self =  bless({}, $class);

    return $self;
}

#######################################
# Event hadling methods for PerlSax   #
#######################################

sub doctype_decl {
    my ($self, $doctype) = @_;
    # make sure we have a tinyseq
    unless ($doctype->{'SystemId'} eq 'http://www.ncbi.nlm.nih.gov/dtd/NCBI_TSeq.dtd') {
	$self->throw("This document doesn't use the NCBI TinySeq dtd; it's a ", $doctype->{'SystemId'} );
    }

}

=head2 start_document

  Title		: start_document
  Usage		: NONE
  Function	: start_document handler for use by XML::Parser::PerlSAX
  Returns	: NONE
  Args		: NONE

=cut

sub start_document {
    my ($self) = @_;

    $self->{'_seqatts'} = [];
    $self->{'_elements'} = [];
}

=head2 end_document

  Title		: end_document
  Usage		: NONE
  Function	: end_document handler for use by XML::Parser::PerlSAX
  Returns	: NONE
  Args		: NONE

=cut

sub end_document {
    my ($self) = @_;
    return $self->{'_seqatts'};
}

=head2 start_element

  Title		: start_element
  Usage		: NONE
  Function	: start_element handler for use by XML::Parser::PerlSAX
  Returns	: NONE
  Args		: NONE

=cut

sub start_element {
    my ($self, $starting) = @_;

    push(@{$self->{'_elements'}}, $starting);
}

=head2 end_element

  Title		: end_element
  Usage		: NONE
  Function	: end_element handler for use by XML::Parser::PerlSAX
  Returns	: NONE
  Args		: NONE

=cut

sub end_element {
    my ($self, $ending) = @_;

    # do I have a handler for this element?
    my $ename = $ending->{'Name'};
    $self->$ename if ($self->can($ename));
}

=head2 characters

  Title		: characters
  Usage		: NONE
  Function	: characters handler for use by XML::Parser::PerlSAX
  Returns	: NONE
  Args		: NONE

=cut

sub characters {
    my ($self, $characters) = @_;

    my $data = $characters->{'Data'};

    return unless (defined($data) and $data =~ /\S/);

    my $current = $self->_current_element;
    $current->{'Data'} = $data;
}


###########################################
# Element-specific handlers
# called at END of element name
##########################################

=head2 TSeq

  Title		: TSeq
  Usage		: NONE
  Function	: event handler for END of a TSeq element
  Returns	: loh of parsed sequence atts for Bio::SeqIO::tinyseq
  Args		: NONE

=cut

sub TSeq {
    my ($self) = @_;

    my %seqatts;

    # map elements onto PrimarySeq keys
    while (my $element = pop @{ $self->{'_elements'} }) {
	my $element_name = $element->{'Name'};
	last if ($element_name eq 'TSeq');

	my $conversion = $ATTMAP{$element_name} or next;

	while(my($element_att, $pseq_att) = each %$conversion) {
	    $seqatts{$pseq_att} = $element->{$element_att};
	}
    }

    push(@{ $self->{'_seqatts'} }, \%seqatts);

}

#############################################
# Utility method to return current element info
##############################################

=head2 _current_element

  Title		: _current_element
  Usage		: Internal method
  Function	: Utility method to return current element info
  Returns	: XML::Parser::PerlSAX hash for current element
  Args		: NONE

=cut

sub _current_element {
    my ($self) = @_;
    return $self->{'_elements'}->[-1];
}




1;
