#-----------------------------------------5~------------------------------------
# PACKAGE : Bio::SeqIO::lasergene
# AUTHOR  : Malcolm Cook <mec@stowers-institute.org>
# CREATED : Feb 16 1999
#
# _History_
#
# This code is based on the Bio::SeqIO::raw module with
# the necessary minor tweaks necessary to get it to read (only)
# Lasergene formatted sequences
#
# Cleaned up by Torsten Seemann June 2006

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::lasergene - Lasergene sequence file input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the L<Bio::SeqIO> class.

=head1 DESCRIPTION

This object can product Bio::Seq::RichSeq objects from Lasergene sequence files.

IT DOES NOT PARSE ANY ATTIBUTE VALUE PAIRS IN THE HEADER OF THE LASERGENE FORMATTED FILE.

IT DOES NOT WRITE THESE FILES EITHER.

=head1 REFERENCES

  https://www.dnastar.com/products/lasergene.php

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
of the bugs and their resolution. Bug reports can be submitted via
the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHORS

  Torsten Seemann - torsten.seemann AT infotech.monash.edu.au
  Malcolm Cook  - mec AT stowers-institute.org

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::SeqIO::lasergene;

use strict;

use base qw(Bio::SeqIO);

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : Bio::Seq object
 Args    : none

=cut

use Bio::Seq;
use Bio::Annotation::Collection;
use Bio::Annotation::Comment;

sub next_seq {
   my ($self) = @_;

   my $state = 0;
   my @comment;
   my @sequence;

   while (my $line = $self->_readline) {
     $state = 1 if $state == 0;
     chomp $line;
     next if $line =~ m/^\s*$/; # skip blank lines

     if ($line eq '^^') {  # end of a comment or sequence
       $state++;
       last if $state > 2; # we have comment and sequence so exit
     }
     elsif ($state == 1) { # another piece of comment
       push @comment, $line;
     }
     elsif ($state == 2) { # another piece of sequence
       push @sequence, $line
     }
     else {
       $self->throw("unreachable state reached, probable bug!");
     }
   }

   # return quietly if there was nothing in the file
   return if $state == 0;

   # ensure we read some comment and some sequence
   if ($state < 2) {
     $self->throw("unexpected end of file");
   }

   my $sequence = join('', @sequence);
#   print STDERR "SEQ=[[$sequence]]\n";
   $sequence or $self->throw("empty sequence in lasergene file");
   my $seq = Bio::Seq->new(-seq => $sequence);

   my $comment = join('; ', @comment);
#   print STDERR "COM=[[$comment]]\n";
   my $anno = Bio::Annotation::Collection->new;
   $anno->add_Annotation('comment', Bio::Annotation::Comment->new(-text => $comment) );
   $seq->annotation($anno);

   return $seq;
}

=head2 write_seq (NOT IMPLEMENTED)

 Title   : write_seq
 Usage   : $stream->write_seq($seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Array of Bio::PrimarySeqI objects

=cut

sub write_seq {
  my ($self, @seq) = @_;
  $self->throw("write_seq() is not implemented for the lasergene format.");
}


1;

