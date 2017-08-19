# BioPerl module for Bio::SeqIO::largefasta
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Jason Stajich
#
# Copyright Jason Stajich
#
# You may distribute this module under the same terms as perl itself
# _history
# 
# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::largefasta - method i/o on very large fasta sequence files

=head1 SYNOPSIS

Do not use this module directly.  Use it via the Bio::SeqIO class.

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from fasta flat
file databases.

This module handles very large sequence files by using the
Bio::Seq::LargePrimarySeq module to store all the sequence data in
a file.  This can be a problem if you have limited disk space on your
computer because this will effectively cause 2 copies of the sequence
file to reside on disk for the life of the
Bio::Seq::LargePrimarySeq object.  The default location for this is
specified by the L<File::Spec>-E<gt>tmpdir routine which is usually /tmp
on UNIX.  If a sequence file is larger than the swap space (capacity
of the /tmp dir) this could cause problems for the machine.  It is
possible to set the directory where the temporary file is located by
adding the following line to your code BEFORE calling next_seq. See
L<Bio::Seq::LargePrimarySeq> for more information.

    $Bio::Seq::LargePrimarySeq::DEFAULT_TEMP_DIR = 'newdir';

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

=head1 AUTHORS - Jason Stajich

Email: jason@bioperl.org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::largefasta;
use vars qw($FASTALINELEN);
use strict;

use Bio::Seq::SeqFactory;

$FASTALINELEN = 60;
use base qw(Bio::SeqIO);

sub _initialize {
  my($self,@args) = @_;
  $self->SUPER::_initialize(@args);    
  if( ! defined $self->sequence_factory ) {
      $self->sequence_factory(Bio::Seq::SeqFactory->new
			      (-verbose => $self->verbose(), 
			       -type => 'Bio::Seq::LargePrimarySeq'));      
  }
}

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : A Bio::Seq::LargePrimarySeq object
 Args    : NONE

=cut

sub next_seq {
    my ($self) = @_;
#  local $/ = "\n";
    my $largeseq = $self->sequence_factory->create();
    my ($id,$fulldesc,$entry);
    my $count = 0;
    my $seen = 0;
    while( defined ($entry = $self->_readline) ) {
	if( $seen == 1 && $entry =~ /^\s*>/ ) {
	    $self->_pushback($entry);
	    return $largeseq;
	}
#	if ( ($entry eq '>') || eof($self->_fh) ) { $seen = 1; next; }      
	if ( ($entry eq '>')  ) { $seen = 1; next; }      
	elsif( $entry =~ /\s*>(.+?)$/ ) {
	    $seen = 1;
	    ($id,$fulldesc) = ($1 =~ /^\s*(\S+)\s*(.*)$/)
		or $self->warn("Can't parse fasta header");
	    $largeseq->display_id($id);
	    $largeseq->primary_id($id);	  
	    $largeseq->desc($fulldesc);
	} else {
	    $entry =~ s/\s+//g;
	    $largeseq->add_sequence_as_string($entry);
	}
	(++$count % 1000 == 0 && $self->verbose() > 0) && print "line $count\n";
    }
    return unless $seen;
    return $largeseq;
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq(@seq)
 Function: writes the $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : Bio::Seq object


=cut

sub write_seq {
   my ($self,@seq) = @_;
   foreach my $seq (@seq) {       
     my $top = $seq->id();
     if ($seq->can('desc') and my $desc = $seq->desc()) {
	 $desc =~ s/\n//g;
	 $top .= " $desc";
     }
     $self->_print (">",$top,"\n");
     my $end = $seq->length();
     my $start = 1;
     while( $start < $end ) {
	 my $stop = $start + $FASTALINELEN - 1;
	 $stop = $end if( $stop > $end );
	 $self->_print($seq->subseq($start,$stop), "\n");
	 $start += $FASTALINELEN;
     }
   }

   $self->flush if $self->_flush_on_write && defined $self->_fh;
   return 1;
}

1;
