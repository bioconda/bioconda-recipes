#-----------------------------------------------------------------------------
# PACKAGE : Bio::SeqIO::tab
# AUTHOR  : Philip Lijnzaad <p.lijnzaad@med.uu.nl>
# CREATED : Feb 6 2003
#
# Copyright (c) This module is free software; you can redistribute it
# and/or modify it under the same terms as Perl itself.
#
# _History_
#
# Ewan Birney <birney@ebi.ac.uk> developed the SeqIO
# schema and the first prototype modules.
#
# This code is based on his Bio::SeqIO::raw
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::tab - nearly raw sequence file input/output
stream. Reads/writes id"\t"sequence"\n"

=head1 SYNOPSIS

Do not use this module directly.  Use it via the L<Bio::SeqIO> class.

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from tabbed flat
file databases.

It is very useful when doing large scale stuff using the Unix command
line utilities (grep, sort, awk, sed, split, you name it). Imagine
that you have a format converter 'seqconvert' along the following
lines:

  my $in  = Bio::SeqIO->newFh(-fh => \*STDIN , '-format' => $from);
  my $out = Bio::SeqIO->newFh(-fh=> \*STDOUT, '-format' => $to);
  print $out $_ while <$in>;

then you can very easily filter sequence files for duplicates as:

  $ seqconvert < foo.fa -from fasta -to tab | sort -u |\
       seqconvert -from tab -to fasta > foo-unique.fa

Or grep [-v] for certain sequences with:

  $ seqconvert < foo.fa -from fasta -to tab | grep -v '^S[a-z]*control' |\
       seqconvert -from tab -to fasta > foo-without-controls.fa

Or chop up a huge file with sequences into smaller chunks with:

  $ seqconvert < all.fa -from fasta -to tab | split -l 10 - chunk-
  $ for i in chunk-*; do seqconvert -from tab -to fasta < $i > $i.fa; done
  # (this creates files chunk-aa.fa, chunk-ab.fa, ..., each containing 10
  # sequences)


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

Philip Lijnzaad, p.lijnzaad@med.uu.nl

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut


# Let the code begin...

package Bio::SeqIO::tab;
use strict;

use Bio::Seq;

use base qw(Bio::SeqIO);

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

   my $nextline = $self->_readline();
   chomp($nextline) if defined $nextline;
   return unless defined $nextline;
   if ($nextline =~ /^([^\t]*)\t(.*)/) {
       my ($id, $seq)=($1, uc($2));
       $seq =~ s/\s+//g;
       return  Bio::Seq->new(-display_id=> $id, -seq => $seq);
   }  else {
       $self->throw("Can't parse tabbed sequence entry:'$nextline' around line $.");
   }
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq($seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Bio::Seq object


=cut

sub write_seq {
   my ($self,@seq) = @_;
   foreach (@seq) {
       if ($_->display_id() =~ /\t/) {
           $self->throw("display_id [".$_->display_id()."] contains TAB -- illegal in tab format");
       }
       $self->_print($_->display_id(), "\t",$_->seq, "\n") or return;
   }

   $self->flush if $self->_flush_on_write && defined $self->_fh;
   return 1;
}

1;
