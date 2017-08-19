# BioPerl module for Bio::SeqIO::bsml_sax
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Jason Stajich
#

=head1 NAME

Bio::SeqIO::bsml_sax - BSML sequence input/output stream using SAX

=head1 SYNOPSIS

 It is probably best not to use this object directly, but rather go
 through the SeqIO handler system. To read a BSML file:

    $stream = Bio::SeqIO->new( -file => $filename, -format => 'bsml');

    while ( my $bioSeqObj = $stream->next_seq() ) {
	# do something with $bioSeqObj
    }

 To write a Seq object to the current file handle in BSML XML format:

    $stream->write_seq( -seq => $seqObj);

 If instead you would like a XML::DOM object containing the BSML, use:

    my $newXmlObject = $stream->to_bsml( -seq => $seqObj);

=head1 DEPENDENCIES

 In addition to parts of the Bio:: hierarchy, this module uses:

 XML::SAX

=head1 DESCRIPTION

 This object can transform Bio::Seq objects to and from BSML (XML)
 flatfiles.

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
 the bugs and their resolution. Bug reports can be submitted via the
 web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Jason Stajich

Email jason-at-bioperl-dot-org

=cut

package Bio::SeqIO::bsml_sax;
use vars qw($Default_Source);
use strict;

use Bio::SeqFeature::Generic;
use Bio::Species;
use XML::SAX;
use Bio::Seq::SeqFactory;
use Bio::Annotation::Collection;
use Bio::Annotation::Comment;
use Bio::Annotation::Reference;
use Bio::Annotation::DBLink;

use base qw(Bio::SeqIO XML::SAX::Base);

$Default_Source = 'BSML';

sub _initialize {
    my ($self) = shift;
    $self->SUPER::_initialize(@_);
    $self->{'_parser'} = XML::SAX::ParserFactory->parser('Handler' => $self);
    if( ! defined $self->sequence_factory ) {
	$self->sequence_factory(Bio::Seq::SeqFactory->new
				(-verbose => $self->verbose(),
				 -type => 'Bio::Seq::RichSeq'));
    }
    return;
}

=head1 METHODS

=cut

=head2 next_seq

 Title   : next_seq
 Usage   : my $bioSeqObj = $stream->next_seq
 Function: Retrieves the next sequence from a SeqIO::bsml stream.
 Returns : A reference to a Bio::Seq::RichSeq object
 Args    :

=cut

sub next_seq {
    my $self = shift;
    if( @{$self->{'_seendata'}->{'_seqs'} || []} ||
	eof($self->_fh)) {
	return shift @{$self->{'_seendata'}->{'_seqs'}};
    }
    $self->{'_parser'}->parse_file($self->_fh);
    return shift @{$self->{'_seendata'}->{'_seqs'}};
}

# XML::SAX::Base methods

sub start_document {
    my ($self,$doc) = @_;
    $self->{'_seendata'} = {'_seqs'    => [],
			    '_authors' => [],
			    '_feats'   => [] };
    $self->SUPER::start_document($doc);
}

sub end_document {
    my ($self,$doc) = @_;
    $self->SUPER::end_document($doc);
}


sub start_element {
    my ($self,$ele) = @_;
    my $name = uc($ele->{'LocalName'});
    my $attr = $ele->{'Attributes'};
    my $seqid = defined $self->{'_seendata'}->{'_seqs'}->[-1] ?
	$self->{'_seendata'}->{'_seqs'}->[-1]->display_id : undef;
    for my $k ( keys %$attr ) {
	$attr->{uc $k} = $attr->{$k};
	delete $attr->{$k};
    }
    if( $name eq 'BSML' ) {

    } elsif( $name eq 'DEFINITIONS' ) {
    } elsif( $name eq 'SEQUENCES' ) {

    } elsif( $name eq 'SEQUENCE' ) {
	my ($id,$acc,$title,
	    $desc,$length,$topology,
	    $mol) =  map { $attr->{'{}'.$_}->{'Value'} } qw(ID IC-ACCKEY
							    TITLE COMMENT
							    LENGTH
							    TOPOLOGY
							    MOLECULE);
	push @{$self->{'_seendata'}->{'_seqs'}},
	$self->sequence_factory->create
	    (
	     -display_id          => $id,
	     -accession_number    => $acc,
	     -description         => $desc,
	     -length              => $length,
	     -is_circular         => ($topology =~ /^linear$/i) ? 0 : 1,
	     -molecule            => $mol,
	     );

    } elsif( $name eq 'FEATURE-TABLES' ) {
    } elsif( $name eq 'ATTRIBUTE' ) {
	my $curseq = $self->{'_seendata'}->{'_seqs'}->[-1];
	my ($name,$content) = map { $attr->{'{}'.$_}->{'Value'} } qw(NAME CONTENT);
	if($name =~ /^version$/i ) {
	    my ($version);
	    if($content =~ /^[^\.]+\.(\d+)/) {
		$version = $1;
	    } else { $version = $content }
	    $curseq->seq_version($version);
	} elsif( $name eq 'organism-species') {
	    my ($genus,$species,$subsp) = split(/\s+/,$content,3);
	    $curseq->species(Bio::Species->new(-sub_species => $subsp,
					       -classification =>
					       [$species,$genus]));
	} elsif( $name eq 'organism-classification' ) {
	    my (@class) =(split(/\s*;\s*/,$content),$curseq->species->species);
	    $curseq->species->classification([reverse @class]);
	} elsif( $name eq 'database-xref' ) {
	    my ($db,$id) = split(/:/,$content);
	    $curseq->annotation->add_Annotation('dblink',
					      Bio::Annotation::DBLink->new
						( -database  => $db,
						  -primary_id=> $id));
	} elsif( $name eq 'date-created' ||
		 $name eq 'date-last-updated' ) {
	    $curseq->add_date($content);
	}
    } elsif( $name eq 'FEATURE' ) {
	my ($id,$class,$type,$title,$display_auto)
	    =  map { $attr->{'{}'.$_}->{'Value'} } qw(ID CLASS VALUE-TYPE
						      TITLE DISPLAY-AUTO);

	push @{$self->{'_seendata'}->{'_feats'}},
	Bio::SeqFeature::Generic->new
	    ( -seq_id      => $self->{'_seendata'}->{'_seqs'}->[-1]->display_id,
	      -source_tag  => $Default_Source,
	      -primary_tag => $type,
	      -tag => {'ID'    => $id,
		   });

    } elsif( $name eq 'QUALIFIER') {
	my ($type,$value) =  map { $attr->{'{}'.$_}->{'Value'} } qw(VALUE-TYPE
								    VALUE);
	my $curfeat = $self->{'_seendata'}->{'_feats'}->[-1];
	$curfeat->add_tag_value($type,$value);
    } elsif( $name eq 'INTERVAL-LOC' ) {
	my $curfeat = $self->{'_seendata'}->{'_feats'}->[-1];
	my ($start,$end,$strand) =
	    map { $attr->{'{}'.$_}->{'Value'} } qw(STARTPOS
						   ENDPOS
						   COMPLEMENT);

	$curfeat->start($start);
	$curfeat->end($end);
	$curfeat->strand(-1) if($strand);
    } elsif( $name eq 'REFERENCE' ) {
	push @{$self->{'_seendata'}->{'_annot'}},
	Bio::Annotation::Reference->new();
    }

    push @{$self->{'_state'}}, $name;
    $self->SUPER::start_element($ele);
}

sub end_element {
    my ($self,$ele) = @_;
    pop @{$self->{'_state'}};
    my $name = uc $ele->{'LocalName'};
    my $curseq = $self->{'_seendata'}->{'_seqs'}->[-1];
    if( $name eq 'REFERENCE') {
	my $ref = pop @{$self->{'_seendata'}->{'_annot'}};
	$curseq->annotation->add_Annotation('reference',$ref);
    } elsif( $name eq 'FEATURE' ) {
	my $feat = pop @{$self->{'_seendata'}->{'_feats'}};
	$curseq->add_SeqFeature($feat);
    }
    $self->SUPER::end_element($ele);
}

sub characters {
    my ($self,$data) = @_;
    if( ! @{$self->{'_state'}} ) {
	$self->warn("Calling characters with no previous start_element call. Ignoring data");
    } else {
	my $curseq = $self->{'_seendata'}->{'_seqs'}->[-1];
	my $curfeat = $self->{'_seendata'}->{'_feats'}->[-1];
	my $curannot = $self->{'_seendata'}->{'_annot'}->[-1];
	my $name = $self->{'_state'}->[-1];
	if( $name eq 'REFAUTHORS' ) {
	    $curannot->authors($data->{'Data'});
	} elsif( $name eq 'REFTITLE') {
	    $curannot->title($data->{'Data'});
	} elsif( $name eq 'REFJOURNAL') {
	    $curannot->location($data->{'Data'});
	} elsif( $name eq 'SEQ-DATA') {
	    $data->{'Data'} =~ s/\s+//g;
	    $curseq->seq($data->{'Data'});
	}
    }
    $self->SUPER::characters($data);
}

1;
