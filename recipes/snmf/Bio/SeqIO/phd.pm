#
# Copyright (c) 1997-2001 bioperl, Chad Matsalla. All Rights Reserved.
#           This module is free software; you can redistribute it and/or
#           modify it under the same terms as Perl itself.
#
# Copyright Chad Matsalla
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::phd - phd file input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the L<Bio::SeqIO> class.

=head1 DESCRIPTION

This object can transform .phd files (from Phil Green's phred basecaller)
to and from Bio::Seq::Quality objects. The phd format is described in section 10
at this url: http://www.phrap.org/phredphrap/phred.html

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

=head1 AUTHOR Chad Matsalla

Chad Matsalla
bioinformatics@dieselwurks.com

=head1 CONTRIBUTORS

Jason Stajich, jason@bioperl.org
Jean-Marc Frigerio, Frigerio@pierroton.inra.fr

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# 'Let the code begin...
#

package Bio::SeqIO::phd;
use strict;
use Bio::Seq::SeqFactory;
use Bio::Seq::RichSeq;
use Bio::Annotation::Collection;
use Bio::Annotation::Comment;
use Dumpvalue;

my $dumper = Dumpvalue->new();

use base qw(Bio::SeqIO);

sub _initialize {
  my($self,@args) = @_;
  $self->SUPER::_initialize(@args);
  if( ! defined $self->sequence_factory ) {
      $self->sequence_factory(Bio::Seq::SeqFactory->new
                  (-verbose => $self->verbose(),
                   -type => 'Bio::Seq::Quality'));
  }
}

=head2 next_seq

 Title   : next_seq()
 Usage   : $swq = $stream->next_seq()
 Function: returns the next phred sequence in the stream
 Returns : Bio::Seq::Quality object
 Args    : NONE

=cut

sub next_seq {
    my ($self,@args) = @_;
    my $seq;
    while (my $entry = $self->_readline) {
        chomp $entry;
        if ($entry =~ /^BEGIN_SEQUENCE\s+(\S+)/) {
            if (defined $seq) {
                # done with current sequence
                $self->_pushback($entry);
                last;
            } else {
                # start new sequence
                my $id = $1;
                $seq = $self->sequence_factory->create(
                    -id         => $id,
                    -primary_id => $id,
                    -display_id => $id,
                );
            }
        } elsif ($entry =~ /^BEGIN_COMMENT/) {
            my $collection = Bio::Annotation::Collection->new;
            while ($entry = $self->_readline) {
                chomp $entry;
                if ($entry =~ /^(\w+):\s+(.+)$/) {
                    my ($name, $content) = ($1, $2);
                    my $comment = Bio::Annotation::Comment->new(
                        -text    => $content,
                        -tagname => $name
                    );
                    $collection->add_Annotation('header',$comment);                  
                } elsif ($entry =~ /^END_COMMENT/) {
                    $seq->Bio::Seq::RichSeq::annotation($collection);
                    last;
                }
            }
        } elsif ($entry =~ /^BEGIN_DNA/) {
            my $dna = '';
            my @qualities = ();
            my @trace_indices = ();
            while ($entry = $self->_readline) {
                chomp $entry;
                if ( $entry =~ /(\S+)\s+(\S+)\s+(\S+)/ ) {
                    # add nucleotide and quality scores to sequence
                    $dna .= $1;
                    push @qualities,$2;
                    push(@trace_indices,$3) if defined $3; # required for phd file
                } elsif ($entry =~ /^END_DNA/) {
                    # end of sequence, save it
                    $seq->seq($dna);
                    $seq->qual(\@qualities);
                    $seq->trace(\@trace_indices);
                    last;
                }
            }
           
        } elsif ($entry =~ /^END_SEQUENCE/) {
            # the sequence may be over, but some other info can come after
            next;
        } elsif ($entry =~ /^WR{/) {
            # Whole-Read items 
            # Programs like Consed or Autofinish add it to phd file. See doc:
            #   http://www.phrap.org/consed/distributions/README.16.0.txt
            #my ($type, $nane, $date, $time) = split(' ',$self->_readline);
            #my $extra_info = '';
            #while ($entry = $self->_readline) {
            #    chomp $entry;
            #    last if ($entry =~ /\}/);
            #    $extra_info .= $entry;
            #}
            ### fea: save WR somewhere? but where?
        } 
    } 
    return $seq;
}


=head2 write_header

 Title   : write_header()
 Usage   : $seqio->write_header()
 Function: Write out the header (BEGIN_COMMENTS .. END_COMMENT) part of a phd file
 Returns : nothing
 Args    : a Bio::Seq::Quality object
 Notes   : These are the comments that reside in the header of a phd file
           at the present time. If not provided by the Bio::Seq::Quality object,
           the following default values will be used:

     CHROMAT_FILE          : $swq->id()
     ABI_THUMBPRINT        : 0
     PHRED_VERSION         : 0.980904.e
     CALL_METHOD           : phred
     QUALITY_LEVELS        : 99
     TIME                  : <current time>
     TRACE_ARRAY_MIN_INDEX : 0
     TRACE_ARRAY_MAX_INDEX : unknown
     CHEM                  : unknown
     DYE                   : unknown

=cut

sub write_header {
    my ($self, $swq) = @_;
    $self->_print("\nBEGIN_COMMENT\n\n");
    #defaults
    my $time = localtime();
    for ([CHROMAT_FILE          =>$swq->attribute('CHROMAT_FILE')],
         [ABI_THUMBPRINT        => 0],
         [PHRED_VERSION         => '0.980904.e'],
         [CALL_METHOD           => 'phred'],
         [QUALITY_LEVELS        => '99'],
         [TIME                  => $time],
         [TRACE_ARRAY_MIN_INDEX => 0],
         [TRACE_ARRAY_MAX_INDEX => 'unknown'],
         [CHEM                  => 'unknown'],
         [DYE                   => 'unknown'])
    {
        $swq->attribute($_->[0],$_->[1]) unless $swq->attribute($_->[0]);
    }
    
    my @annot = $swq->annotation->get_Annotations('header');
    for (@annot) {
        $self->_print($_->tagname,": ",$_->text,"\n");
        }
    $self->_print("\nEND_COMMENT\n\n");
    $self->flush if $self->_flush_on_write && defined $self->_fh;
    return 1;
}

=head2 write_seq

 Title   : write_seq()
 Usage   : $seqio->write_seq($swq);
 Function: Write out a phd file.
 Returns : Nothing.
 Args    : a Bio::Seq::Quality object

=cut

sub write_seq {
    my ($self,$swq) = @_;

    $self->throw("You must pass a Bio::Seq::Quality object to write_seq")
        unless (ref($swq) eq "Bio::Seq::Quality");

    $self->throw("Can't create the phd because the sequence and the quality in the Quality object are of different lengths.")
        unless $swq->length() ne 'DIFFERENT';

    $self->_print("BEGIN_SEQUENCE ".$swq->id()."\n");
    $self->write_header($swq);
    $self->_print("BEGIN_DNA\n");
    for my $curr(1 ..  $swq->length()) {
    $self->_print (sprintf("%s %s %s\n",
                   uc($swq->baseat($curr)),
                   $swq->qualat($curr),
                   $swq->trace_index_at($curr)));
    }
    $self->_print ("END_DNA\n\nEND_SEQUENCE\n");

    $self->flush if $self->_flush_on_write && defined $self->_fh;
    return 1;
}

=head2 attribute

 Title   : attribute()
 Usage   : swq->attribute(name[,value]);
 Function: Get/Set the name attribute.
 Returns : a string if 1 param, nothing else.
 Args    : a name or a pair name, value

=cut

sub Bio::Seq::Quality::attribute {
    my ($self, $name, $value) = @_;
    my $collection = $self->annotation;
    my @annot = $collection->get_Annotations('header');
    my %attribute;
    my $annot;
    for (@annot) {
        $attribute{$_->tagname} = $_->display_text;
        $annot = $_ if $_->tagname eq $name;
    }


    unless (defined $attribute{$name}) { #new comment
        my $comment =
                Bio::Annotation::Comment->new(-text => $value || 'unknown');
        $comment->tagname($name);
        $collection->add_Annotation('header',$comment);
        return;
    }

    return $attribute{$name} unless (defined $value);#get

    #print "ATTRIBUTE ",$annot," $name $attribute{$name}\n";
    $annot->text($value); #set
    return;
}


=head2 chromat_file

 Title   : chromat_file
 Usage   : swq->chromat_file([filename]);
 Function: Get/Set the CHROMAT_FILE attribute.
 Returns : a string if 1 param, nothing else.
 Args    : none or a filename

=cut

sub Bio::Seq::Quality::chromat_file {
    my ($self,$arg) =  @_;
    return $self->attribute('CHROMAT_FILE',$arg);
}

=head2 abi_thumbprint

 Title   : abi_thumbprint
 Usage   : swq->abi_thumbprint([value]);
 Function: Get/Set the ABI_THUMBPRINT attribute.
 Returns : a string if 1 param, nothing else.
 Args    : none or a value

=cut

sub Bio::Seq::Quality::abi_thumbprint {
    my ($self,$arg) =  @_;
    return $self->attribute('ABI_THUMBPRINT',$arg);
}

=head2 phred_version

 Title   : phred_version
 Usage   : swq->phred_version([value]);
 Function: Get/Set the PHRED_VERSION attribute.
 Returns : a string if 1 param, nothing else.
 Args    : none or a value 

=cut


sub Bio::Seq::Quality::phred_version {
    my ($self,$arg) =  @_;
    return $self->attribute('PHRED_VERSION', $arg);
   }


=head2 call_method

 Title   : call_method
 Usage   : swq->call_method([value]);
 Function: Get/Set the CALL_METHOD attribute.
 Returns : a string if 1 param, nothing else.
 Args    : none or a value 

=cut

sub Bio::Seq::Quality::call_method {
    my ($self,$arg) =  @_;
    return $self->attribute('CALL_METHOD', $arg);
    }

=head2 quality_levels

 Title   : quality_levels
 Usage   : swq->quality_levels([value]);
 Function: Get/Set the quality_levels attribute.
 Returns : a string if 1 param, nothing else.
 Args    : none or a value

=cut

sub Bio::Seq::Quality::quality_levels {
    my ($self,$arg) =  @_;
    return $self->attribute('QUALITY_LEVELS', $arg);
    }

=head2 trace_array_min_index

 Title   : trace_array_min_index
 Usage   : swq->trace_array_min_index([value]);
 Function: Get/Set the trace_array_min_index attribute.
 Returns : a string if 1 param, nothing else.
 Args    : none or a value

=cut

sub Bio::Seq::Quality::trace_array_min_index {
    my ($self,$arg) =  @_;
    return $self->attribute('TRACE_ARRAY_MIN_INDEX', $arg);
 }

=head2 trace_array_max_index

 Title   : trace_array_max_index
 Usage   : swq->trace_array_max_index([value]);
 Function: Get/Set the trace_array_max_index attribute.
 Returns : a string if 1 param, nothing else.
 Args    : none or a value

=cut

sub Bio::Seq::Quality::trace_array_max_index {
    my ($self,$arg) =  @_;
    return $self->attribute('TRACE_ARRAY_MAX_INDEX', $arg);
}

=head2 chem

 Title   : chem
 Usage   : swq->chem([value]);
 Function: Get/Set the chem attribute.
 Returns : a string if 1 param, nothing else.
 Args    : none or a value

=cut

sub Bio::Seq::Quality::chem {
    my ($self,$arg) =  @_;
    return $self->attribute('CHEM', $arg);
}

=head2 dye

 Title   : dye
 Usage   : swq->dye([value]);
 Function: Get/Set the dye attribute.
 Returns : a string if 1 param, nothing else.
 Args    : none or a value

=cut

sub Bio::Seq::Quality::dye {
    my ($self,$arg) =  @_;
    return $self->attribute('DYE', $arg);
}

=head2 time

 Title   : time
 Usage   : swq->time([value]);
 Function: Get/Set the time attribute.
 Returns : a string if 1 param, nothing else.
 Args    : none or a value

=cut

sub Bio::Seq::Quality::time {
    my ($self,$arg) =  @_;
    return $self->attribute('TIME', $arg);
}

=head2 touch

 Title   : touch
 Usage   : swq->touch();
 Function: Set the time attribute to current time.
 Returns : nothing
 Args    : none

=cut

sub Bio::Seq::Quality::touch {
    my $time = localtime();
    shift->attribute('TIME',$time);
    return;
}

1;
