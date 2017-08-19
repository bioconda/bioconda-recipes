#
# BioPerl module for Bio::SeqIO::MultiFile
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

Bio::SeqIO::MultiFile - Treating a set of files as a single input stream

=head1 SYNOPSIS

   my $seqin = Bio::SeqIO::MultiFile->new( -format => 'Fasta',
                                           -files  => ['file1','file2'] );
   while (my $seq = $seqin->next_seq) {
       # do something with $seq
   }

=head1 DESCRIPTION

Bio::SeqIO::MultiFile provides a simple way of bundling a whole
set of identically formatted sequence input files as a single stream.
File format is automatically determined by C<Bio::SeqIO>.

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

=head1 AUTHOR - Ewan Birney

Email birney@ebi.ac.uk

=head1 APPENDIX

The rest of the documentation details each of the object methods. Internal methods are usually preceded with a _

=cut


# Let the code begin...


package Bio::SeqIO::MultiFile;
use strict;

use base qw(Bio::SeqIO);


# _initialize is where the heavy stuff will happen when new is called

sub _initialize {
    my($self, @args) = @_;

    $self->SUPER::_initialize(@args);

    my ($file_array, $format) = $self->_rearrange([qw(FILES FORMAT)], @args);
    if( !defined $file_array || ! ref $file_array ) {
        $self->throw("Must have an array files for MultiFile");
    }

    $self->{'_file_array'} = [];
    $self->_set_file(@$file_array);

    $self->format($format) if defined $format;

    if( $self->_load_file() == 0 ) {
        $self->throw("Unable to initialise the first file");
    }
}


=head2 next_seq

 Title   : next_seq
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut

sub next_seq{
    my ($self, @args) = @_;
    my $seq = $self->_current_seqio->next_seq();
    if( !defined $seq ) {
        if( $self->_load_file() == 0) {
            return;
        } else {
            return $self->next_seq();
        }
    } else {
        return $seq;
    }
}


=head2 next_primary_seq

 Title   : next_primary_seq
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut

sub next_primary_seq{
    my ($self, @args) = @_;
    my $seq = $self->_current_seqio->next_primary_seq();
    if( !defined $seq ) {
        if( $self->_load_file() == 0) {
            return;
        } else {
            return $self->next_primary_seq();
        }
    } else {
        return $seq;
    }
}


=head2 _load_file

 Title   : _load_file
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut

sub _load_file{
    my ($self, @args) = @_;
    my $file = shift @{$self->{'_file_array'}};
    if( !defined $file ) {
        return 0;
    }
    my $seqio;
    my $format = $self->format;
    if ($format) {
        $seqio = Bio::SeqIO->new( -file => $file, -format => $format );
    } else {
        $seqio = Bio::SeqIO->new( -file => $file );
        $self->format($seqio->format) if not $format;
    }

    # should throw an exception - but if not...
    if( !defined $seqio) {
        $self->throw("Could not build SeqIO object for $file!");
    }
    $self->_current_seqio($seqio);
    return 1;
}


=head2 _set_file

 Title   : _set_file
 Usage   :
 Function:
 Example :
 Returns :
 Args    :

=cut

sub _set_file{
    my ($self, @files) = @_;
    push @{$self->{'_file_array'}}, @files;
}


=head2 _current_seqio

 Title   : _current_seqio
 Usage   : $obj->_current_seqio($newval)
 Function:
 Example :
 Returns : value of _current_seqio
 Args    : newvalue (optional)

=cut

sub _current_seqio{
    my ($obj, $value) = @_;
    if( defined $value) {
        $obj->{'_current_seqio'} = $value;
    }
    return $obj->{'_current_seqio'};
}


# We overload the format() method of Bio::Root::IO by a simple get/set

sub format{
    my ($obj, $value) = @_;
    if( defined $value) {
        $obj->{'_format'} = $value;
    }
    return $obj->{'_format'};
}


1;
