#
# BioPerl module for Bio::SeqIO::gcg
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Ewan Birney <birney@ebi.ac.uk>
#          and Lincoln Stein <lstein@cshl.org>
#
# Copyright Ewan Birney & Lincoln Stein
#
# You may distribute this module under the same terms as perl itself
#
# _history
# October 18, 1999  Largely rewritten by Lincoln Stein

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::gcg - GCG sequence input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the Bio::SeqIO class.

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from GCG flat
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
the bugs and their resolution.  Bug reports can be submitted via the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHORS - Ewan Birney & Lincoln Stein

Email: E<lt>birney@ebi.ac.ukE<gt>
       E<lt>lstein@cshl.orgE<gt>

=head1 CONTRIBUTORS

Jason Stajich, jason@bioperl.org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::gcg;
use strict;

use Bio::Seq::SeqFactory;

use base qw(Bio::SeqIO);

sub _initialize {
  my($self,@args) = @_;
  $self->SUPER::_initialize(@args);
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
 Returns : Bio::Seq object
 Args    :

=cut

sub next_seq {
   my ($self,@args)    = @_;
   my($id,$type,$desc,$line,$chksum,$sequence,$date,$len);

   while( defined($_ = $self->_readline()) ) {

       ## Get the descriptive info (anything before the line with '..')
       unless( /\.\.$/ ) { $desc.= $_; }
       ## Pull ID, Checksum & Type from the line containing '..'
       /\.\.$/ && do     { $line = $_; chomp;
                           if(/Check\:\s(\d+)\s/) { $chksum = $1; }
                           if(/Type:\s(\w)\s/)    { $type   = $1; }
                           if(/(\S+)\s+Length/)
			   { $id     = $1; }
			   if(/Length:\s+(\d+)\s+(\S.+\S)\s+Type/ )
			   { $len = $1; $date = $2;}
                           last;
                         }
   }
   return if ( !defined $_);
   chomp($desc);  # remove last "\n"

   while( defined($_ = $self->_readline()) ) {

       ## This is where we grab the sequence info.

       if( /\.\.$/ ) {
        $self->throw("Looks like start of another sequence. See documentation. ");
       }

       next if($_ eq "\n");       ## skip whitespace lines in formatted seq
       s/[\d\s\t]//g;            ## remove anything that is not alphabet char: preserve anything that is not explicitly specified for removal (Stefan Kirov)
       # $_ = uc($_);               ## uppercase sequence: NO. Keep the case. HL
       $sequence .= $_;
   }
   ##If we parsed out a checksum, we might as well test it

   if(defined $chksum) {
       unless(_validate_checksum(uc($sequence),$chksum)) {
	   $self->throw("Checksum failure on parsed sequence.");
       }
   }

   ## Remove whitespace from identifier because the constructor
   ## will throw a warning otherwise...
   if(defined $id) { $id =~ s/\s+//g;}

   ## Turn our parsed "Type: N" or "Type: P" (if found) into the appropriate
   ## keyword that the constructor expects...
   if(defined $type) {
       if($type eq "N") { $type = "dna";      }
       if($type eq "P") { $type = "prot";    }
   }

   return $self->sequence_factory->create(-seq  => $sequence,
					  -id   => $id,
					  -desc => $desc,
					  -type => $type,
					  -dates => [ $date ]
					  );
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq(@seq)
 Function: writes the formatted $seq object into the stream
 Returns : 1 for success and 0 for error
 Args    : array of Bio::PrimarySeqI object


=cut

sub write_seq {
    my ($self,@seq) = @_;
    for my $seq (@seq) {
	$self->throw("Did not provide a valid Bio::PrimarySeqI object")
	    unless defined $seq && ref($seq) && $seq->isa('Bio::PrimarySeqI');

        $self->warn("No whitespace allowed in GCG ID [". $seq->display_id. "]")
            if $seq->display_id =~ /\s/;

	my $str         = $seq->seq;
	my $comment     = $seq->desc || '';
	my $id          = $seq->id;
	my $type        = ( $seq->alphabet() =~ /[dr]na/i ) ? 'N' : 'P';
	my $timestamp;

	if( $seq->can('get_dates') ) {
	    ($timestamp) = $seq->get_dates;
	} else {
	    $timestamp = localtime(time);
	}
	my($sum,$offset,$len,$i,$j,$cnt,@out);

	$len = length($str);
	## Set the offset if we have any non-standard numbering going on
	$offset=1;
	# checksum
	$sum = $self->GCG_checksum($seq);

	#Output the sequence header info
	push(@out,"$comment\n");
	push(@out,"$id  Length: $len  $timestamp  Type: $type  Check: $sum  ..\n\n");

	#Format the sequence
	$i = $#out + 1;
	for($j = 0 ; $j < $len ; ) {
	    if( $j % 50 == 0) {
		$out[$i] = sprintf("%8d  ",($j+$offset)); #numbering
	    }
	    $out[$i] .= sprintf("%s",substr($str,$j,10));
	    $j += 10;
	    if( $j < $len && $j % 50 != 0 ) {
		$out[$i] .= " ";
	    }elsif($j % 50 == 0 ) {
		$out[$i++] .= "\n\n";
	    }
	}
	local($^W) = 0;
	if($j % 50 != 0 ) {
	    $out[$i] .= "\n";
	}
	$out[$i] .= "\n";
	return unless $self->_print(@out);
    }

    $self->flush if $self->_flush_on_write && defined $self->_fh;
    return 1;
}

=head2 GCG_checksum

 Title     : GCG_checksum
 Usage     : $cksum = $gcgio->GCG_checksum($seq);
 Function  : returns a gcg checksum for the sequence specified

             This method can also be called as a class method.
 Example   :
 Returns   : a GCG checksum string
 Argument  : a Bio::PrimarySeqI implementing object

=cut

sub GCG_checksum {
    my ($self,$seqobj) = @_;
    my $index = 0;
    my $checksum = 0;
    my $char;

    my $seq = $seqobj->seq();
    $seq =~ tr/a-z/A-Z/;

    foreach $char ( split(/[\.\-]*/, $seq)) {
	$index++;
	$checksum += ($index * (unpack("c",$char) || 0) );
	if( $index ==  57 ) {
	    $index = 0;
	}
    }

    return ($checksum % 10000);
}

=head2 _validate_checksum

 Title   : _validate_checksum
 Usage   : n/a - internal method
 Function: if parsed gcg sequence contains a checksum field
         : we compare it to a value computed here on the parsed
         : sequence. A checksum mismatch would indicate some
         : type of parsing failure occured.
         :
 Returns : 1 for success, 0 for failure
 Args    : string containing parsed seq, value of parsed cheksum


=cut

sub _validate_checksum {
    my($seq,$parsed_sum) = @_;
    my($i,$len,$computed_sum,$cnt);

    $len = length($seq);

    #Generate the GCG Checksum value

    for($i=0; $i<$len ;$i++) {
	$cnt++;
	$computed_sum += $cnt * ord(substr($seq,$i,1));
	($cnt == 57) && ($cnt=0);
    }
    $computed_sum %= 10000;

    ## Compare and decide if success or failure

    if($parsed_sum == $computed_sum) {
	return 1;
    } else { return 0; }


}

1;
