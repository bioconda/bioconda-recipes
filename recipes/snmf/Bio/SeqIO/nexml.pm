# BioPerl module for Bio::SeqIO::nexml
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Chase Miller <chmille4@gmail.com>
#
# Copyright Chase Miller
#
# You may distribute this module under the same terms as perl itself
# _history
# May, 2009  Largely written by Chase Miller

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::nexml - NeXML sequence input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the Bio::SeqIO class.

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from NeXML format.
For more information on the NeXML standard, visit L<http://www.nexml.org>.

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
the bugs and their resolution.  Bug reports can be submitted via the
web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHORS - Chase Miller

Email: chmille4@gmail.com

=head1 CONTRIBUTORS

Mark Jensen, maj@fortinbras.us
Rutger Vos, rutgeraldo@gmail.com

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::nexml;

use strict;

use lib '../..';
use Bio::Seq;
use Bio::Seq::SeqFactory;
use Bio::Nexml::Factory;
use Bio::Phylo::IO qw (parse unparse);

use base qw(Bio::SeqIO);

sub _initialize {
  my($self,@args) = @_;
  $self->SUPER::_initialize(@args); 
  $self->{_doc} = undef; 
}

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : L<Bio::Seq> object
 Args    : NONE

=cut

sub next_seq {
	my ($self) = @_;
    unless ( $self->{'_parsed'} ) {
    	#use a parse function to load all the sequence objects found in the nexml file at once
        $self->_parse;
    }
    return $self->{'_seqs'}->[ $self->{'_seqiter'}++ ];
}

=head2 rewind

 Title   : rewind
 Usage   : $seqio->rewind
 Function: Resets the stream
 Returns : none
 Args    : none


=cut

sub rewind {
    my $self = shift;
    $self->{'_seqiter'} = 0;
}

=head2 doc

 Title   : doc
 Usage   : $treeio->doc
 Function: Returns the biophylo nexml document object
 Returns : Bio::Phylo::Project
 Args    : none or Bio::Phylo::Project object

=cut

sub doc {
	my ($obj,$value) = @_;
   if( defined $value) {
      $obj->{'_doc'} = $value;
	}
	return $obj->{'_doc'};
}

sub _parse {
	my ($self) = @_;
	my $fac = Bio::Nexml::Factory->new();
	
    $self->{'_parsed'}   = 1;
    $self->{'_seqiter'} = 0;
	
	$self->doc(Bio::Phylo::IO->parse(
 	'-file'       => $self->{'_file'},
 	'-format'     => 'nexml',
 	'-as_project' => '1'
 	));
 
 	
 		
 	$self->{'_seqs'} = $fac->create_bperl_seq($self);
 		
 	
 	unless(@{ $self->{'_seqs'} } == 0)
 	{
# 		self->debug("no seqs in $self->{_file}");
 	}
 }
 
 
 

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq(@seq)
 Function: Writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Array of 1 or more L<Bio::PrimarySeqI> objects

=cut

sub write_seq {
	
	my ($self, $bp_seq) = @_;
	
	my $fac = Bio::Nexml::Factory->new();
	my $taxa = $fac->create_bphylo_taxa($bp_seq);
	my ($seq) = $fac->create_bphylo_seq($bp_seq, $taxa);
	
	my $matrix = Bio::Phylo::Factory->create_matrix('-type' => $seq->get_type());
	$matrix->insert($seq);
	$matrix->set_taxa($taxa);
	
	#set matrix label
	my $feat = ($bp_seq->get_SeqFeatures())[0];
	$matrix->set_name($feat->get_tag_values('matrix_label'));
	
	$self->doc(Bio::Phylo::Factory->create_project());
	
	$self->doc->insert($matrix);
	
	my $ret = $self->_print($self->doc->to_xml());
	$self->flush;
	return $ret
}


1;
