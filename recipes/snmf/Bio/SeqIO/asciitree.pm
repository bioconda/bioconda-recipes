#
# BioPerl module for Bio::SeqIO::asciitree
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Chris Mungall <cjm@fruitfly.org>
#
# Copyright Chris Mungall
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::asciitree - asciitree sequence input/output stream

=head1 SYNOPSIS

  # It is probably best not to use this object directly, but
  # rather go through the SeqIO handler system. Go:

    $instream  = Bio::SeqIO->new(-file => $filename,
                                 -format => 'chadoxml');
    $outstream = Bio::SeqIO->new(-file => $filename,
                                 -format => 'asciitree');

    while ( my $seq = $instream->next_seq() ) {
	    $outstream->write_seq();
    }


=head1 DESCRIPTION

This is a WRITE-ONLY SeqIO module. It writes a Bio::SeqI object
containing nested SeqFeature objects in such a way that the SeqFeature
containment hierarchy is visible as a tree structure


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

=head1 AUTHOR - Chris Mungall

Email cjm@fruitfly.org

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::asciitree;
use strict;


use base qw(Bio::SeqIO);

sub _initialize {
    my($self,@args) = @_;

    $self->SUPER::_initialize(@args);
    # hash for functions for decoding keys.
}

=head2 show_detail

 Title   : show_detail
 Usage   : $obj->show_detail($newval)
 Function:
 Example :
 Returns : value of show_detail (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub show_detail{
    my $self = shift;

    return $self->{'show_detail'} = shift if @_;
    return $self->{'show_detail'};
}


=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : Bio::Seq object
 Args    :

=cut

sub next_seq {
    my ($self,@args) = @_;
    $self->throw("This is a WRITE-ONLY adapter");
}


=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq($seq)
 Function: writes the $seq object (must be seq) to the stream
 Returns : 1 for success and 0 for error
 Args    : array of 1 to n Bio::SeqI objects

=cut

sub write_seq {
    my ($self,@seqs) = @_;

    foreach my $seq ( @seqs ) {
	$self->throw("Attempting to write with no seq!") unless defined $seq;

	if( ! ref $seq || ! $seq->isa('Bio::SeqI') ) {
	    $self->warn(" $seq is not a SeqI compliant module. Attempting to dump, but may fail!");
	}
	$self->_print("Seq: ".$seq->accession_number);
	$self->_print("\n");
	my @top_sfs = $seq->get_SeqFeatures;
	$self->write_indented_sf(1, @top_sfs);
    }
}

sub write_indented_sf {
    my $self = shift;
    my $indent = shift;
    my @sfs = @_;
    foreach my $sf (@sfs) {
        my $label = '';
        if ($sf->has_tag('standard_name')) {
            ($label) = $sf->get_tag_values('standard_name');
        }
        if ($sf->has_tag('product')) {
            ($label) = $sf->get_tag_values('product');
        }
	my $COLS = 60;
	my $tab = ' ' x 10;
	my @lines = ();
	if ($self->show_detail) {
	    my @tags = $sf->all_tags;
	    foreach my $tag (@tags) {
		my @vals = $sf->get_tag_values($tag);
		foreach my $val (@vals) {
		    $val = "\"$val\"";
		    push(@lines,
			 "$tab/$tag=");
		    while (my $cut =
			   substr($val, 0, $COLS - length($lines[-1]), '')) {
			$lines[-1] .= "$cut";
			if ($val) {
			    push(@lines, $tab);
			}
		    }
		}
	    }
	}
	my $detail = join("\n", @lines);

        my @sub_sfs = $sf->get_SeqFeatures;
	my $locstr = '';
	if (!@sub_sfs) {
	    $locstr = $self->_locstr($sf);
	}
        my $col1 = sprintf("%s%s $label",
			   '  ' x $indent, $sf->primary_tag);
	my $line = sprintf("%-50s %s\n",
			   substr($col1, 0, 50), $locstr);
	$self->_print($line);
	if ($detail) {
	    $self->_print($detail."\n");
	}
	$self->write_indented_sf($indent+1, @sub_sfs);
    }
    return;
}

sub _locstr {
    my $self = shift;
    my $sf = shift;
    my $strand = $sf->strand || 0;
    my $ss = '.';
    $ss = '+' if $strand > 0;
    $ss = '-' if $strand < 0;

    my $splitlocstr = '';
    if ($sf->isa("Bio::SeqFeatureI")) {
        my @locs = ($sf->location);
        if ($sf->location->isa("Bio::Location::SplitLocationI")) {
            @locs = $sf->location->each_Location;
            $splitlocstr = "; SPLIT: ".join(" ",
                                          map {$self->_locstr($_)} @locs);

        }
    }

    return
      sprintf("%d..%d[%s] $splitlocstr", $sf->start, $sf->end, $ss);
}

1;
