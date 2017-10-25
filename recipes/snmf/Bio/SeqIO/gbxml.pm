# $Id: gbxml.pm
# 
# BioPerl module for Bio::SeqIO::gbxml
#
# Cared for by Ryan Golhar
# NOTE: This module is implemented on an as needed basis.  As features
# are needed, they are implemented.  Its very bare-bones.
#
# Based off http://www.insdc.org/page.php?page=documents&sid=105a8b52b69db9c36c82a2e0d923ca69
#
# I tried to follow the genbank module to keep things as consistent as possible
# Right now, I'm not respecting the want_slot parameters.  This will need to be added.

=head1 NAME

Bio::SeqIO::gbxml - GenBank sequence input/output stream using SAX

=head1 SYNOPSIS

It is probably best not to use this object directly, but rather go
through the SeqIO handler system. To read a GenBank XML file:

   $stream = Bio::SeqIO->new( -file => $filename, -format => 'gbxml');

   while ( my $bioSeqObj = $stream->next_seq() ) {
	# do something with $bioSeqObj
   }

To write a Seq object to the current file handle in GenBank XML format:

   $stream->write_seq( -seq => $seqObj);

If instead you would like a XML::DOM object containing the GBXML, use:

   my $newXmlObject = $stream->to_bsml( -seq => $seqObj);

=head1 DEPENDENCIES

In addition to parts of the Bio:: hierarchy, this module uses:

XML::SAX

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from GenBank XML
flatfiles.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.  Your participation is much appreciated.

 bioperl-l@bioperl.org                  - General discussion
 http://bioperl.org/wiki/Mailing_lists  - About the mailing lists

=head2 Reporting Bugs

Report bugs to the Bioperl bug tracking system to help us keep track
the bugs and their resolution. Bug reports can be submitted via the
web:

 https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Ryan Golhar

Email golharam-at-umdnj-dot-edu

=cut

package Bio::SeqIO::gbxml;
use vars qw($Default_Source);
use strict;

use Bio::SeqIO::FTHelper;
use Bio::SeqFeature::Generic;
use Bio::Species;
use XML::SAX;
use Bio::Seq::SeqFactory;
use Bio::Annotation::Collection;
use Bio::Annotation::Comment;
use Bio::Annotation::Reference;
use Bio::Annotation::DBLink;

use base qw(Bio::SeqIO XML::SAX::Base);

$Default_Source = 'GBXML';

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
Function: Retrieves the next sequence from a SeqIO::gbxml stream.
Returns : A reference to a Bio::Seq::RichSeq object
Args    :

=cut

sub next_seq {
   my $self = shift;
   if( @{$self->{'_seendata'}->{'_seqs'} || []} || eof($self->_fh)) {
	return shift @{$self->{'_seendata'}->{'_seqs'}};
   }   
   $self->{'_parser'}->parse_file($self->_fh);
   return shift @{$self->{'_seendata'}->{'_seqs'}};
}

# XML::SAX::Base methods

sub start_document {
   my ($self,$doc) = @_;
   $self->{'_seendata'} = {'_seqs'    => [] #,
#			    '_authors' => [],
#			    '_feats'   => []
			   };
   $self->SUPER::start_document($doc);
}

sub end_document {
   my ($self,$doc) = @_;
   $self->SUPER::end_document($doc);
}


sub start_element {
	my ($self,$ele) = @_;
	my $name = uc($ele->{'LocalName'});

#	my $attr = $ele->{'Attributes'};
#	my $seqid = defined $self->{'_seendata'}->{'_seqs'}->[-1] ?
#		$self->{'_seendata'}->{'_seqs'}->[-1]->display_id : undef;

#	for my $k ( keys %$attr ) {
#		$attr->{uc $k} = $attr->{$k};
#		delete $attr->{$k};
#	}	
	
	if( $name eq 'GBSET' ) {
	
	} elsif( $name eq 'GBSEQ' ) {
		# Initialize, we are starting a new sequence.
		push @{$self->{'_seendata'}->{'_seqs'}},
			$self->sequence_factory->create();
	} elsif( $name eq 'GBFEATURE' ) {
		my $curseq = $self->{'_seendata'}->{'_seqs'}->[-1];
		my $fthelper = Bio::SeqIO::FTHelper->new();
		$fthelper->verbose($self->verbose());
		push @{$self->{'_seendata'}->{'_feats'}}, $fthelper;
	}
	
#    } elsif( $name eq 'FEATURE-TABLES' ) {
#	} elsif( $name eq 'database-xref' ) {
#	    my ($db,$id) = split(/:/,$content);
#	    $curseq->annotation->add_Annotation('dblink',
#					      Bio::Annotation::DBLink->new
#						( -database  => $db,
#						  -primary_id=> $id));
#    } elsif( $name eq 'INTERVAL-LOC' ) {
#	my $curfeat = $self->{'_seendata'}->{'_feats'}->[-1];
#	my ($start,$end,$strand) =
#	    map { $attr->{'{}'.$_}->{'Value'} } qw(STARTPOS
#						   ENDPOS
#						   COMPLEMENT);

#	$curfeat->start($start);
#	$curfeat->end($end);
#	$curfeat->strand(-1) if($strand);
#    } elsif( $name eq 'REFERENCE' ) {
#	push @{$self->{'_seendata'}->{'_annot'}},
#	Bio::Annotation::Reference->new();
#    }
	$self->{'_characters'} = '';
	
	push @{$self->{'_state'}}, $name;
	$self->SUPER::start_element($ele);
}

sub end_element {
	my ($self,$ele) = @_;
	pop @{$self->{'_state'}};
	my $name = uc $ele->{'LocalName'};
	my $curseq = $self->{'_seendata'}->{'_seqs'}->[-1];
	my $curfeat = $self->{'_seendata'}->{'_feats'}->[-1];     
	
	if ($name eq 'GBSEQ_LOCUS') {
		$curseq->display_id($self->{'_characters'});
	
	} elsif ($name eq 'GBSEQ_LENGTH' ) {	
		$curseq->length($self->{'_characters'});	
	
	} elsif ($name eq 'GBSEQ_MOLTYPE' ) {
		if ($self->{'_characters'} =~ /mRNA|dna/) {
			$curseq->alphabet('dna');
		} else {
			$curseq->alphabet('protein');
		}
		$curseq->molecule($self->{'_characters'});
	
	} elsif ($name eq 'GBSEQ_TOPOLOGY' ) {
		$curseq->is_circular(($self->{'_characters'} =~ /^linear$/i) ? 0 : 1);

	} elsif ($name eq 'GBSEQ_DIVISION' ) {
		$curseq->division($self->{'_characters'});

	} elsif ($name =~ m/GBSEQ_UPDATE-DATE|GBSEQ_CREATE-DATE/ ) {
		my $date = $self->{'_characters'};
		# This code was taken from genbank.pm
		if($date =~ s/\s*((\d{1,2})-(\w{3})-(\d{2,4})).*/$1/) {
			if( length($date) < 11 ) { # improperly formatted date
				# But we'll be nice and fix it for them
				my ($d,$m,$y) = ($2,$3,$4);
				$d = "0$d" if( length($d) == 1 );
				# guess the century here
				if( length($y) == 2 ) {
					# arbitrarily guess that '60' means 1960
					$y = ($y > 60) ? "19$y" : "20$y";
					$self->warn("Date was malformed, guessing the century for $date to be $y\n");
				}
				$date = [join('-',$d,$m,$y)];
			} 
			$curseq->add_date($date);
		}

	} elsif ($name eq 'GBSEQ_DEFINITION' ) {
		$curseq->description($self->{'_characters'});

	} elsif ($name eq 'GBSEQ_PRIMARY-ACCESSION' ) {		
		$curseq->accession_number($self->{'_characters'});

	} elsif ($name eq 'GBSEQ_ACCESSION-VERSION' ) {
		# also taken from genbank.pm
		$self->{'_characters'} =~ m/^\w+\.(\d+)/;
		if ($1) {
			$curseq->version($1);
			$curseq->seq_version($1);
		}

	} elsif ($name eq 'GBSEQID' ) {
		if ($self->{'_characters'} =~ m/gi\|(\d+)/) {
			$curseq->primary_id($1);
		}

	} elsif ($name eq 'GBSEQ_SOURCE') {
		$self->{'_taxa'}->{'_common'} = $self->{'_characters'};

	} elsif ($name eq 'GBSEQ_ORGANISM' ) {
		# taken from genbank.pm
		my @organell_names = ("chloroplast", "mitochondr");
		my @spflds = split(' ', $self->{'_characters'});
			
		$_ = $self->{'_characters'};
		if (grep { $_ =~ /^$spflds[0]/i; } @organell_names) {
			$self->{'_taxa'}->{'_organelle'} = shift(@spflds);
		}
		$self->{'_taxa'}->{'_genus'} = shift(@spflds);
		$self->{'_taxa'}->{'_species'} = shift(@spflds) if (@spflds);
		$self->{'_taxa'}->{'_sub_species'} = shift(@spflds) if (@spflds);
		$self->{'_taxa'}->{'_ns_name'} = $self->{'_characters'};
		
	} elsif ($name eq 'GBSEQ_TAXONOMY' ) {
		# taken from genbank.pm
		$_ = $self->{'_characters'};
		my @class;
		push (@class, map { s/^\s+//; s/\s+$//; $_; } split /[;\.]+/, $_);
			
		next unless $self->{'_taxa'}->{'_genus'} and $self->{'_taxa'}->{'_genus'} !~ /^(unknown|None)$/oi;
		if ($class[0] eq 'Viruses') {
			push( @class, $self->{'_taxa'}->{'_ns_name'} );
		}
		elsif ($class[$#class] eq $self->{'_taxa'}->{'_genus'}) {
			push( @class, $self->{'_taxa'}->{'_species'} );
		} else {
			push( @class, $self->{'_taxa'}->{'_genus'}, $self->{'_taxa'}->{'_species'} );
		}
		@class = reverse @class;
			
		my $make = Bio::Species->new();
		$make->classification( \@class, "FORCE");
		$make->common_name($self->{'_taxa'}->{'_common'}) if $self->{'_taxa'}->{'_common'};
		unless ($class[-1] eq 'Viruses') {
			$make->sub_species( $self->{'_taxa'}->{'_sub_species'} ) if $self->{'_taxa'}->{'_sub_species'};
		}		
		$make->organelle( $self->{'_taxa'}->{'_organelle'} ) if $self->{'_taxa'}->{'_organelle'};			
		$curseq->species($make);
		delete $self->{'_taxa'};				

	} elsif( $name eq 'GBSEQ_COMMENT' ) {
		$curseq->annotation->add_Annotation('comment', Bio::Annotation::Comment->new(-text => $self->{'_characters'} )) if ($self->{'_characters'});
		
	} elsif ($name eq 'GBFEATURE_KEY' ) {
		$curfeat->key($self->{'_characters'});
		
	} elsif ($name eq 'GBFEATURE_LOCATION' ) {		
		$curfeat->loc($self->{'_characters'});
		
	} elsif ($name eq 'GBQUALIFIER_NAME' ) {
		$self->{'_feature'}->{"_qualifer_name"} = $self->{'_characters'};

	} elsif ($name eq 'GBQUALIFIER_VALUE' ) {
		my $qualifier = $self->{'_feature'}->{"_qualifer_name"};
		delete $self->{'_feature'}->{"_qualifer_name"};
			
		$curfeat->field->{$qualifier} ||= [];
		push(@{$curfeat->field->{$qualifier}}, $self->{'_characters'});
		
	} elsif ($name eq 'GBSEQ_SEQUENCE' ) {
		$curseq->seq($self->{'_characters'});
		
	} elsif( $name eq 'GBFEATURE' ) {
		shift @{$self->{'_seendata'}->{'_feats'}};
		# copied from genbank.pm
		if (!defined($curfeat)) {
			$self->warn("Unexpected error in feature table for ".$curseq->display_id." Skipping feature, attempting to recover");
		} else {
			my $feat = $curfeat->_generic_seqfeature($self->location_factory(), $curseq->display_id);
			if ($curseq->species && ($feat->primary_tag eq 'source') &&
			    $feat->has_tag('db_xref') && (! $curseq->species->ncbi_taxid())) {
				foreach my $tagval ($feat->get_tag_values('db_xref')) {
					if (index($tagval,"taxon:") == 0) {
						$curseq->species->ncbi_taxid(substr($tagval,6));
					}
				}
			}
			$curseq->add_SeqFeature($feat);
		}
	}
	
#    if( $name eq 'REFERENCE') {
#	my $ref = pop @{$self->{'_seendata'}->{'_annot'}};
#	$curseq->annotation->add_Annotation('reference',$ref);
#    }
   $self->SUPER::end_element($ele);
}

# Characters should be buffered because we may not always get the entire string.  Once the entire string is read
# process it in end_element.
sub characters {
	my ($self,$data) = @_;
	if( ! @{$self->{'_state'}} ) {
		$self->warn("Calling characters with no previous start_element call. Ignoring data");
	} else {
#		my $curseq = $self->{'_seendata'}->{'_seqs'}->[-1];
#		my $curfeat = $self->{'_seendata'}->{'_feats'}->[-1];
#		my $curannot = $self->{'_seendata'}->{'_annot'}->[-1];
#		my $name = $self->{'_state'}->[-1];

#		if ($name eq 'GBSEQ_LOCUS' ) {
			$self->{'_characters'} .= $data->{'Data'};
			
#		} elsif ($name eq 'GBSEQ_LENGTH' ) {
#			$self->{'_characters'} .= $data->{'Data'};

#		} elsif ($name eq 'GBSEQ_MOLTYPE' ) {
#			$self->{'_characters'} .= $data->{'Data'};

#		} elsif ($name eq 'GBSEQ_TOPOLOGY' ) {
#			$self->{'_characters'} .= $data->{'Data'};

#		} elsif ($name eq 'GBSEQ_DIVISION' ) {
#			$self->{'_characters'} .= $data->{'Data'};	

#		} elsif ($name =~ m/GBSEQ_UPDATE-DATE|GBSEQ_CREATE-DATE/ ) {
#			$self->{'_characters'} .= $data->{'Data'};	

#		} elsif ($name eq 'GBSEQ_DEFINITION' ) {
#			$self->{'_characters'} .= $data->{'Data'};	

#		} elsif ($name eq 'GBSEQ_PRIMARY-ACCESSION' ) {		
#			$self->{'_characters'} .= $data->{'Data'};	
					
#		} elsif ($name eq 'GBSEQ_ACCESSION-VERSION' ) {
#			$self->{'_characters'} .= $data->{'Data'};
						
#		} elsif ($name eq 'GBSEQID' ) {
#			$self->{'_characters'} .= $data->{'Data'};
			
#		} elsif ($name eq 'GBSEQ_SOURCE') {
#			$self->{'_characters'} .= $data->{'Data'};
				
#		} elsif ($name eq 'GBSEQ_ORGANISM' ) {
#			$self->{'_characters'} .= $data->{'Data'};
			
#		} elsif ($name eq 'GBSEQ_TAXONOMY' ) {
#			$self->{'_characters'} .= $data->{'Data'};
			
#		} elsif ($name eq 'GBSEQ_COMMENT' ) {
#			$self->{'_characters'} .= $data->{'Data'};

#		} elsif ($name eq 'GBFEATURE_KEY' ) {
#			$self->{'_characters'} .= $data->{'Data'};

#		} elsif ($name eq 'GBFEATURE_LOCATION' ) {		
#			$self->{'_characters'} .= $data->{'Data'};

#		} elsif ($name eq 'GBQUALIFIER_NAME' ) {
#			$self->{'_characters'} .= $data->{'Data'};

#		} elsif ($name eq 'GBQUALIFIER_VALUE' ) {
#			$self->{'_characters'} .= $data->{'Data'};
			
#		} elsif ($name eq 'GBINTERVAL_FROM' ) {		
#			$self->{'_feature'}->{'_interval_from'} = $data->{'Data'};

#		} elsif ($name eq 'GBINTERVAL_TO' ) {		
#			$self->{'_feature'}->{'_interval_to'} = $data->{'Data'};

#		} elsif ($name eq 'GBINTERVAL_ACCESSION' ) {		
#			$self->{'_feature'}->{'_interval_accession'} = $data->{'Data'};

#		} elsif ($name eq 'GBSEQ_SEQUENCE' ) {
#			$self->{'_characters'} .= $data->{'Data'};
#		}
	}	
	$self->SUPER::characters($data);
}

1;

