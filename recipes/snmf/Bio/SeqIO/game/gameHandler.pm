# $Id: 
#
# BioPerl module for Bio::SeqIO::game::gameHandler
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Sheldon McKay <mckays@cshl.edu>
#
# You may distribute this module under the same terms as perl itself
#

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::game::gameHandler -- PerlSAX handler for game-XML

=head1 SYNOPSIS

This modules is not used directly

=head1 DESCRIPTION

Bio::SeqIO::game::gameHandler is the top-level XML handler invoked by PerlSAX

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
to one of the Bioperl mailing lists.

Your participation is much appreciated.

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
of the bugs and their resolution. Bug reports can be submitted via the
web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Sheldon McKay

Email mckays@cshl.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

package Bio::SeqIO::game::gameHandler;

use Bio::SeqIO::game::seqHandler;
use strict;
use vars qw {};

use base qw(Bio::SeqIO::game::gameSubs);

=head2 start_document

 Title   : start_document
 Function: begin parsing the document

=cut

sub start_document {
    my ($self, $document) = @_;

    $self->SUPER::start_document($document);
    
    $self->{sequences}    = {};
    $self->{annotations}  = {};
    $self->{computations} = {};
    $self->{map_position} = {};
    $self->{focus}        = {};
}

=head2 end_document

 Title   : end_document
 Function: finish parsing the document

=cut

sub end_document {
    my ($self, $document) = @_;
    
    $self->SUPER::end_document($document);
    
    return $self;    
}

=head2 load

 Title   : load
 Usage   : $seqs = $handler->load
 Function: start parsing
 Returns : a ref to a list of sequence objects
 Args    : an optional flag to supress <computation_analysis> elements (not used yet)

=cut

sub load {
    my $self = shift;
    my $suppress_comps = shift;
    my @seqs = ();
    
    for ( 1..$self->{game} ) {
        my $seq  = $self->{sequences}->{$_} 
	  or $self->throw("No sequences defined");
        my $ann  = $self->{annotations}->{$_};
        my $comp = $self->{computations}->{$_};
	my $map  = $self->{map_position}->{$_};
        my $foc  = $self->{focus}->{$_}
	  or $self->throw("No main sequence defined");
	my $src  = $self->{has_source};
	
	my $bio = Bio::SeqIO::game::seqHandler->new( $seq, $ann, $comp, $map, $src );
	push @seqs, $bio->convert;
    }
    
    \@seqs;
}

=head2 s_game

 Title   : s_game
 Function: begin parsing game element

=cut

sub s_game {
    my ($self, $e) = @_;
    my $el = $self->curr_element;
    $self->{game}++;
    
    my $version = $el->{Attributes}->{version};
    
    unless ( defined $version ) {
	$self->complain("No GAME-xml version specified -- guessing v1.2\n");
        $version = 1.2;
    }
    if ( defined($version) && $version == 1.2) {
        $self->{origin_offset} = 1;
    } else {
	$self->{origin_offset} = 0;
    }

    if (defined($version) && ($version != 1.2)) {
        $self->complain("GAME version $version is not supported\n",
		        "I'll try anyway but I may fail!\n");
    }
    
}

=head2 e_game

 Title   : e_game
 Function: process the game element

=cut

sub e_game {
    my ($self, $el) = @_;
    $self->flush( $el );
}

=head2 e_seq

 Title   : e_seq
 Function: process the sequence element

=cut

sub e_seq {
    my ($self, $e) = @_;
    my $el = $self->curr_element();
    $self->{sequences}->{$self->{game}} ||= [];
    my $seqs = $self->{sequences}->{$self->{game}};
    
    if ( defined $el->{Attributes}->{focus} ) {
	$self->{focus}->{$self->{game}} = $el;
    }
    push @{$seqs}, $el;
    
    $self->flush;
}

=head2 e_map_position

 Title   : e_map_position
 Function: process the map_position element

=cut

sub e_map_position {
    my ($self, $e) = @_;
    my $el = $self->curr_element;
    $self->{map_position}->{$self->{game}} = $el;
}

=head2 e_annotation

 Title   : e_annotation
 Function: process the annotation

=cut

sub e_annotation {
    my ($self, $e) = shift;
    my $el = $self->curr_element;
    $self->{annotations}->{$self->{game}} ||= [];
    my $anns = $self->{annotations}->{$self->{game}};
    push @{$anns}, $el;
}

1;
