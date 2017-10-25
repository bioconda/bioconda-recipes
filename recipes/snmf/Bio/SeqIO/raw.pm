#-----------------------------------------------------------------------------
# PACKAGE : Bio::SeqIO::raw
# AUTHOR  : Ewan Birney <birney@ebi.ac.uk>
# CREATED : Feb 16 1999
#
# Copyright (c) 1997-9 bioperl, Ewan Birney. All Rights Reserved.
#           This module is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# _History_
#
# Ewan Birney <birney@ebi.ac.uk> developed the SeqIO
# schema and the first prototype modules.
#
# This code is based on his Bio::SeqIO::Fasta module with
# the necessary minor tweaks necessary to get it to read
# and write raw formatted sequences made by
# chris dagdigian <dag@sonsorol.org>
#
# October 18, 1999  Largely rewritten by Lincoln Stein
#
# Copyright Ewan Birney
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::raw - raw sequence file input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the L<Bio::SeqIO> class.

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from raw flat
file databases.

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
the bugs and their resolution.
Bug reports can be submitted via the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHORS

  Ewan Birney   E<lt>birney@ebi.ac.ukE<gt>
  Lincoln Stein E<lt>lstein@cshl.orgE<gt>

=head1 CONTRIBUTORS

  Jason Stajich E<lt>jason@bioperl.org<gt>

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::SeqIO::raw;
use strict;

use Bio::Seq::SeqFactory;

use base qw(Bio::SeqIO);

our %variant = ( 'multiple' => undef, # default
                 'single'   => undef );

sub _initialize {
    my($self,@args) = @_;
    $self->SUPER::_initialize(@args);
    my ($variant) = $self->_rearrange([qw(VARIANT)], @args);
    $variant ||= 'multiple';
    $self->variant($variant);
    $self->{record_separator} = $variant eq 'single' ? undef : $/;
    if( ! defined $self->sequence_factory ) {
        $self->sequence_factory(Bio::Seq::SeqFactory->new
                    (-verbose => $self->verbose(),
                     -type => 'Bio::Seq'));
    }
    $self->variant;
}

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : Bio::Seq object
 Args    :


=cut

sub next_seq{
    my ($self,@args) = @_;
    ## When its 1 sequence per line with no formatting at all,
    ## grabbing it should be easy :)
 
    ## adding an option to assume the file is one sequence
    local $/ = $self->{record_separator};
    my $nextline = $self->_readline();
    return unless defined $nextline;
 
    my $sequence = uc($nextline);
    $sequence =~ s/\W//g;
    return unless $sequence;
    return $self->sequence_factory->create(-seq => $sequence) if $sequence;
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq($seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Array of Bio::PrimarySeqI objects


=cut

sub write_seq {
    my ($self,@seq) = @_;
    foreach my $seq (@seq) {
        $self->throw("Must provide a valid Bio::PrimarySeqI object")
            unless defined $seq && ref($seq) && $seq->isa('Bio::PrimarySeqI');
        $self->_print($seq->seq, "\n") or return;
    }
    $self->flush if $self->_flush_on_write && defined $self->_fh;
    return 1;
}

=head2 write_qual

 Title   : write_qual
 Usage   : $stream->write_qual($seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Bio::Seq::Quality object


=cut

sub write_qual {
    my ($self,@seq) = @_;
    my @qual = ();
    foreach (@seq) {
        unless ($_->isa("Bio::Seq::Quality")){
           warn("You cannot write raw qualities without supplying a Bio::Seq::".
                "Quality object! You passed a ".ref($_)."\n");
           next;
        }
        @qual = @{$_->qual};
        if(scalar(@qual) == 0) {
           $qual[0] = "\n";
        }
        $self->_print (join " ", @qual,"\n") or return;
    }
    return 1;
}

=head2 variant

 Title   : variant
 Usage   : $format  = $obj->variant();
 Function: Get and set method for the sequence variant.  For raw sequence, this
           indicates whether to treat the input as multiple sequences (the
           default) or as a single sequence.

           Current values accepted are:

            'single'    single sequence
            'multiple'  multiple sequences (default)
 Returns : string
 Args    : new value, string

=cut

# variant() method inherited from Bio::Root::IO

# private method for testing record separator

sub _separator {
    shift->{record_separator};
}

1;
