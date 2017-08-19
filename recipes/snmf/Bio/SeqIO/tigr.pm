# BioPerl module for Bio::SeqIO::tigr
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Josh Lauricha (laurichj@bioinfo.ucr.edu)
#
# Copyright Josh Lauricha
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::tigr - TIGR XML sequence input/output stream

=head1 SYNOPSIS

Do not use this module directly.  Use it via the Bio::SeqIO class.

=head1 DESCRIPTION

This object can transform Bio::Seq objects to and from efa flat
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

=head1 AUTHORS - Josh Lauricha

Email: laurichj@bioinfo.ucr.edu


=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# TODO:
#  - Clean up code
#  - Find and fix bugs ;)

# Let the code begin...
package Bio::SeqIO::tigr;
use strict;

use Bio::Seq::RichSeq;
use Bio::Species;
use Bio::Annotation::Comment;
use Bio::SeqFeature::Generic;
use Bio::Seq::SeqFactory;
use Bio::Seq::RichSeq;
use Data::Dumper;
use Error qw/:try/;

use base qw(Bio::SeqIO);

sub _initialize
{
	my($self, @args) = @_;

	$self->SUPER::_initialize(@args);
	$self->sequence_factory(Bio::Seq::SeqFactory->new(
			-type => 'Bio::Seq::RichSeq')
	);

	# Parse the document
	$self->_process();
}

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : Bio::Seq object
 Args    : NONE

=cut

sub next_seq()
{
	my ($self) = @_;
	
	# Check for any more sequences
	return if !defined($self->{_sequences}) or scalar(@{$self->{_sequences}}) < 1;

	# get the next sequence
	my $seq = shift(@{ $self->{_sequences} } );

	# Get the 5' and 3' ends
	my ($source) = grep { $_->primary_tag() eq 'source' } $seq->get_SeqFeatures();
	my ($end5) = $source->get_tag_values('end5');
	my ($end3) = $source->get_tag_values('end3');

	# Sort the 5' and 3':
	my ($start, $end) = ( $end5 < $end3  ? ( $end5, $end3 ) : ( $end3, $end5 ) );

	# make the start a perl index
	$start -= 1;

	# Figure out the length
	my $length = $end - $start;

	# check to make sure $start >= 0 and $end <= length(assembly_seq)
    if($start < 0) {
        throw Bio::Root::OutOfRange("the sequence start is $start < 0");
    } elsif($end > length($self->{_assembly}->{seq})) {
        throw Bio::Root::OutOfRange("the sequence end is $end < " . length($self->{_assembly}->{seq}));
    } elsif($start >= $end) {
        throw Bio::Root::OutOfRange("the sequence start is after end $start >= $end");
    }

	# Get and set the real sequence
	$seq->seq(substr($self->{_assembly}->{seq}, $start, $length));

	if( $end5 > $end3 ) {
		# Reverse complement the sequence
		$seq->seq( $seq->primary_seq()->revcom()->seq() );
	}

	# add the translation to each CDS
	foreach my $feat ($seq->get_SeqFeatures()) {
		next if $feat->primary_tag() ne "CDS";

		# Check for an invalid protein
		try {
			# Get the subsq
			my $cds = Bio::PrimarySeq->new(
				-strand => 1,
				-id  => $seq->accession_number(),
				-seq => $seq->subseq($feat->location())
			);

			# Translate it
			my $trans = $cds->translate(undef, undef, undef, undef, 1, 1)->seq();

			# Add the tag
			$feat->add_tag_value(translation => $trans);
		} catch Bio::Root::Exception with {
			print STDERR 'TIGR strikes again, the CDS is not a valid protein: ', $seq->accession_number(), "\n"
				if $self->verbose() > 0;
		};
	}

	# Set the display id to the accession number if there
	# is no display id
	$seq->display_id( $seq->accession_number() ) unless $seq->display_id();
	
	return $seq;
}

sub _process
{
	my($self) = @_;
	my $line;
	my $tu = undef;

	$line = $self->_readline();
	do {
		if($line =~ /<\?xml\s+version\s+=\s+"\d+\.\d+"\?>/o) {
			# do nothing
		} elsif ($line =~ /<!DOCTYPE (\w+) SYSTEM "[\w\.]+">/o) {
			$self->throw("DOCTYPE of $1, not TIGR!")
				if $1 ne "TIGR" ;
		} elsif ($line =~ /<TIGR>/o) {
			$self->_pushback($line);
			$self->_process_tigr();
		} elsif ($line =~ /<ASSEMBLY.*?>/o) {
			$self->_pushback($line);
			$self->_process_assembly();
		} elsif ($line =~ /<\/TIGR>/o) {
			$self->{'eof'}     = 1;
			return;
		} else {
			$self->throw("Unknown or Invalid process directive:",
				join('', ($line =~ /^\s*(<[^>]+>)/o)));
		}
		$line = $self->_readline();
	} while( defined( $line ) );
}

sub _process_tigr
{
	my($self) = @_;
	my $line;

	$line = $self->_readline();
	if($line !~ /<TIGR>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_tigr called but no ",
		             "<TIGR> found in stream");
	}

	$line = $self->_readline();
	if($line =~ /<PSEUDOCHROMOSOME>/o) {
		$self->_pushback($line);
		$self->_process_pseudochromosome();
	} elsif ($line =~ /<ASSEMBLY.*?>/o) {
		$self->_pushback($line);
		$self->_process_assembly();
	}
}

sub _process_pseudochromosome
{
	my($self) = @_;
	my $line;

	$line = $self->_readline();
	return if $line !~ /<PSEUDOCHROMOSOME>/o;

	$line = $self->_readline();

	if($line =~ /<SCAFFOLD>/o) {
		$self->_pushback($line);
		$self->_process_scaffold();
		$line = $self->_readline();
	} else {
		$self->warn( "No Scaffold found in <PSUEDOCHROMOSOME> this " .
		             "is a violation of the TIGR dtd, but we ignore " .
		             "it so we are ignoring the error\n"
		);
	}

	if($line =~ /<ASSEMBLY.*>/o) {
		$self->_pushback($line);
		$self->_process_assembly();
		$line = $self->_readline();
	} else {
		$self->throw("Missing required ASSEMBLY in <PSEUDOCHROMOSOME>");
	}

	if($line =~ /<\/PSEUDOCHROMOSOME>/) {
		return;
	}

	$self->throw("Reached end of _process_psuedochromosome");
}

sub _process_assembly
{
	my($self) = @_;
	my $line;

	$line = $self->_readline();
	if($line !~ /<ASSEMBLY([^>]*)>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_assembly called ",
		             "but no <ASSEMBLY> found in stream");
	}

	my %attribs = ($1 =~ /(\w+)\s*=\s+"(.*?)"/og);
	$self->{_assembly}->{date}       = $attribs{CURRENT_DATE};
	$self->{_assembly}->{db}         = $attribs{DATABASE};
	$self->{_assembly}->{chromosome} = $attribs{CHROMOSOME};

	$line = $self->_readline();
	my($attr, $val); 
	if(($attr, $val) = ($line =~ /<ASMBL_ID([^>]*)>([^<]*)<\/ASMBL_ID>/o)) {
		%attribs = ($attr =~ /(\w+)\s*=\s+"(.*?)"/og);
		$self->{_assembly}->{clone_name} = $attribs{CLONE_NAME};
		$self->{_assembly}->{clone} = $val;
		$line = $self->_readtag();
	} else {
		$self->throw("Required <ASMBL_ID> missing");
	}

	if($line =~ /<COORDSET>/o) {
		$self->_pushback($line);
		my $cs = $self->_process_coordset();

		$self->{_assembly}->{end5} = $cs->{end5};
		$self->{_assembly}->{end3} = $cs->{end3};

		$line = $self->_readline();
	} else {
		$self->throw("Required <COORDSET> missing");
	}

	if($line =~ /<HEADER>/o) {
		$self->_pushback($line);
		$self->_process_header();
		$line = $self->_readline();
	} else {
		$self->throw("Required <HEADER> missing");
	}

	if($line =~ /<TILING_PATH>/o) {
		$self->_pushback($line);
		$self->_process_tiling_path();
		$line = $self->_readline();
	}

	if($line =~ /<GENE_LIST>/o) {
		$self->_pushback($line);
		$self->_process_gene_list();
		$line = $self->_readline();
	} else {
		$self->throw("Required <GENE_LIST> missing");
	}

	if($line =~ /<MISC_INFO>/o) {
		$self->_pushback($line);
		$self->_process_misc_info();
		$line = $self->_readline();
	}

	if($line =~ /<REPEAT_LIST>/o) {
		$self->_pushback($line);
		$self->_process_repeat_list();
		$line = $self->_readline();
	}

	if($line =~ /<ASSEMBLY_SEQUENCE>/o) {
		$self->_pushback($line);
		$self->_process_assembly_seq();
		$line = $self->_readline();
	} else {
		$self->throw("Required <ASSEMBLY_SEQUENCE> missing");
	}

	if($line =~ /<\/ASSEMBLY>/o) {
		return;
	}
	$self->throw("Reached the end of <ASSEMBLY>");
}

sub _process_assembly_seq()
{
	my ($self) = @_;
	my $line;
	
	$line = $self->_readline();
	if($line !~ /<ASSEMBLY_SEQUENCE>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_assembly_seq called ".
			     "with no <ASSEMBLY_SEQUENCE> in the stream");
	}

	# Protect agains lots of smaller lines
	my @chunks;

	do {
		$line = $self->_readline();
		last unless $line;

		my $seq;
		if (($seq) = ($line =~ /^\s*(\w+)\s*$/o)) {
			push(@chunks, $seq);
		} elsif( ($seq) = ( $line =~ /^\s*(\w+)<\/ASSEMBLY_SEQUENCE>\s*$/o) ) {
			push(@chunks, $seq);
			$self->{_assembly}->{seq} = join('', @chunks);
			return;
		}
	} while( $line );

	$self->throw("Reached end of _proces_assembly");
}

sub _process_coordset($)
{
	my ($self) = @_;
	my $line;
	my $h;

	$line = $self->_readline();
	if($line =~ /<COORDSET>/o) {
		$self->_pushback($line);
		$line = $self->_readtag();
		($h->{end5}, $h->{end3}) = ($line =~ /<COORDSET>\s*<END5>\s*(\d+)\s*<\/END5>\s*<END3>\s*(\d+)\s*<\/END3>/os);
		if(!defined($h->{end5}) or !defined($h->{end3})) {
			$self->throw("Invalid <COORDSET>: $line");
		}
		return $h;
	} else {
		$self->throw("Bio::SeqIO::tigr::_process_coordset() called ",
		             "but no <COORDSET> found in stream");
	}
}

sub _process_header
{
	my ($self) = @_;
	my $line = $self->_readline();

	if($line !~ /<HEADER>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_header called ",
		             "but no <HEADER> found in stream");
	}

	$line = $self->_readtag();
	if($line =~ /<CLONE_NAME>([^>]+)<\/CLONE_NAME>/o) {
		$self->{_assembly}->{clone_name} = $1;
		$line = $self->_readtag();
	} else {
		$self->throw("Required <CLONE_NAME> missing");
	}

	if($line =~ /<SEQ_LAST_TOUCHED>/o) {
		# Ignored for now
		$line = $self->_readtag();
	} else {
		$self->throw("Reqired <SEQ_LAST_TOUCHED> missing");
	}

	if($line =~ /<GB_ACCESSION>([^<]*)<\/GB_ACCESSION>/o) {
		$self->{_assembly}->{gb} = $1;
		$line = $self->_readtag();
	} else {
		$self->throw("Required <GB_ACCESSION> missing");
	}

	if($line =~ /<ORGANISM>\s*(.+)\s*<\/ORGANISM>/o) {
		my( $genus, $species, @ss ) = split(/\s+/o, $1);
		$self->{_assembly}->{species} = Bio::Species->new();
		$self->{_assembly}->{species}->genus($genus);
		$self->{_assembly}->{species}->species($species);
		$self->{_assembly}->{species}->sub_species(join(' ', @ss)) if scalar(@ss) > 0;

		$line = $self->_readtag();
	} else {
		$self->throw("Required <ORGANISM> missing");
	}

	if($line =~ /<LINEAGE>([^<]*)<\/LINEAGE>/o) {
		$self->{_assembly}->{species}->classification(
			$self->{_assembly}->{species}->species(),
			reverse(split(/\s*;\s*/o, $1))
		);
		$line = $self->_readtag();
	} else {
		$self->throw("Required <LINEAGE> missing");
	}

	if($line =~ /<SEQ_GROUP>([^<]*)<\/SEQ_GROUP>/o) {
		# ingnored
		$line = $self->_readtag();
	} else {
		$self->throw("Required <SEQ_GROUP> missing");
	}

	while($line =~ /<KEYWORDS>[^<]*<\/KEYWORDS>/o) {
		push(@{$self->{_assembly}->{keywords}}, $1);
		$line = $self->_readtag();
	}

	while($line =~ /<GB_DESCRIPTION>([^<]+)<\/GB_DESCRIPTION>/o) {
		push(@{$self->{_assembly}->{gb_desc}},$1);
		$line = $self->_readtag();
	}

	while($line =~ /<GB_COMMENT>([^<]+)<\/GB_COMMENT>/o) {
		push(@{$self->{_assembly}->{gb_comment}}, $1);
		$line = $self->_readtag();
	}

	if(my %h = ($line =~ /<AUTHOR_LIST(?:\s*(\w+)\s*=\s*"([^"]+)"\s*)*>/o)) {
		#$header->{'AUTHOR_LIST'}=$h{'CONTACT'};
		# Ignored
		while($line !~ /<\/AUTHOR_LIST>/o) {
			$self->_readtag();
		}
		$line = $self->_readline();
	} else {
		$self->throw("Required <AUTHOR_LIST> missing");
	}

	if($line =~ /<\/HEADER>/o) {
		return;
	}

	$self->throw("Reached end of header\n");
}

sub _process_gene_list
{
	my($self) = @_;
	my $line;

	$line = $self->_readline();
	if($line !~ /<GENE_LIST>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_gene_list called ",
		             "but no <GENE_LIST> in the stream");
	}

	$line = $self->_readline();
	if($line =~ /<PROTEIN_CODING>/o) {
		$self->_pushback($line);
		$self->_process_protein_coding();
		$line = $self->_readline();
	} else {
		$self->throw("Required <PROTEIN_CODING> missing");
	}

	if($line =~ /<RNA_GENES>/o) {
		$self->_pushback($line);
		$self->_process_rna_genes();
		$line = $self->_readline();
	} else {
		$self->throw("Required <RNA_GENES> missing");
	}

	if($line =~ /<\/GENE_LIST>/o) {
		return;
	}

	$self->throw("Reached end of _process_gene_list");
}

sub _process_protein_coding
{
	my ($self) = @_;
	my $line = $self->_readline();

	if($line !~ /<PROTEIN_CODING>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_protein_coding called"
		             . "but no <GENE_LIST> in the stream");
	}

	$line = $self->_readline();
	while($line and $line =~ /<TU>/o) {
		$self->_pushback($line);
		$self->_process_tu();
		$line = $self->_readline();
	}

	# Sort the sequences
	@{$self->{_sequences}} = sort {
		my($one, $two) = ( $a, $b );
		($one) = grep { $_->primary_tag() eq 'source' } $one->get_SeqFeatures();
		($two) = grep { $_->primary_tag() eq 'source' } $two->get_SeqFeatures();
		return 0 unless defined $one and defined $two;
		($one) = sort { $a <=> $b } $one->get_tagset_values(qw/end5 end3/);
		($two) = sort { $a <=> $b } $two->get_tagset_values(qw/end5 end3/);
		return $one <=> $two;
	} @{$self->{_sequences}};

	if($line =~ /<\/PROTEIN_CODING>/o) {
		return;
	}

	$self->throw("Reached end of _process_protein_coding");
}


sub _process_rna_genes
{
	my ($self) = @_;
	my $line = $self->_readline();

	if($line =~ /<RNA_GENES>/o) {
		while($line !~ /<\/RNA_GENES>/o) {
			$line = $self->_readline();
		}
	} else {
		$self->throw("Bio::SeqIO::tigr::_process_rna_genes called ",
		             "but no <RNA_GENES> in the stream");
	}
}

sub _process_misc_info
{
	my ($self) = @_;
	my $line = $self->_readline();

	if($line =~ /<MISC_INFO>/o) {
		while($line !~ /<\/MISC_INFO>/o) {
			$line = $self->_readline();
		}
	} else {
		$self->throw("Bio::SeqIO::tigr::_process_misc_info called ",
		             "but no <MISC_INFO> in the stream");
	}
}

sub _process_repeat_list
{
	my ($self) = @_;
	my $line = $self->_readline();

	if($line =~ /<REPEAT_LIST>/o) {
		while($line !~ /<\/REPEAT_LIST>/o) {
			$line = $self->_readline();
		}
	} else {
		$self->throw("Bio::SeqIO::tigr::_process_repeat_list called ",
		             "but no <MISC_INFO> in the stream");
	}
}

sub _process_tiling_path
{
	my($self) = @_;
	my $line = $self->_readline();


	if($line =~ /<TILING_PATH>/o) {
		while($line !~ /<\/TILING_PATH>/o) {
			$line = $self->_readline();
		}
	} else {
		$self->throw("Bio::SeqIO::tigr::_process_repeat_list called ",
		             "but no <MISC_INFO> in the stream");
	}
}

sub _process_scaffold
{
	my ($self) = @_;
	my $line;

	# for now we just skip them
	$line = $self->_readline();
	return if $line !~ /<SCAFFOLD>/o;
	do {
		$line = $self->_readline();
	} while(defined($line) && $line !~ /<\/SCAFFOLD>/o);
}

sub _process_tu
{
	my($self) = @_;
	my $line = $self->_readline();

	try {
		my $tu = Bio::Seq::RichSeq->new(-strand => 1);
		$tu->species( $self->{_assembly}->{species} );

		# Add the source tag, so we can add the GO annotations to it
		$tu->add_SeqFeature(Bio::SeqFeature::Generic->new(-source_tag => 'TIGR', -primary_tag => 'source'));
		
		if($line !~ /<TU>/o) {
			$self->throw("Process_tu called when no <TU> tag");
		}

		$line = $self->_readtag();
		if ($line =~ /<FEAT_NAME>([\w\.]+)<\/FEAT_NAME>/o) {
			$tu->accession_number($1);
			$tu->add_secondary_accession($1);
			$line = $self->_readtag();
		} else {
			$self->throw("Invalid Feat_Name");
		}

		while($line =~ /<GENE_SYNONYM>/o) {
			# ignore
			$line = $self->_readtag();
		}
	
		while($line =~ /<CHROMO_LINK>\s*([\w\.]+)\s*<\/CHROMO_LINK>/o) {
			$tu->add_secondary_accession($1);
			$line = $self->_readtag();
		}

		if ($line =~ /<DATE>([^>]*)<\/DATE>/o) {
			$tu->add_date($1) if $1 and $1 !~ /^\s*$/o;
			$line = $self->_readline();
		} else {
			#$self->throw("Invalid Date: $line");
		}

		if ($line =~ /<GENE_INFO>/o) {
			$self->_pushback($line);
			$self->_process_gene_info($tu);
			$line = $self->_readline();
		} else {
			$self->throw("Invalid Gene_Info");
		}

		my $source;
		my $end5;
		my $end3;
		if($line =~ /<COORDSET>/o) {
			$self->_pushback($line);
			my $cs = $self->_process_coordset();
	
			$end5 = $cs->{end5};
			$end3 = $cs->{end3};

			my $length = $end3 - $end5;
			my $strand = $length <=> 0;
			$length = $length * $strand;
			$length++; # Correct for starting at 1, not 0

			# Add X filler sequence
			$tu->seq('X' x $length);

			# Get the source tag:
			my($source) = grep { $_->primary_tag() eq 'source' } $tu->get_SeqFeatures();

			# Set the start and end values
			$source->start(1);
			$source->end($length);
			$source->strand(1);

			# Add a bunch of tags to it
			$source->add_tag_value(clone      => $self->{_assembly}->{clone});
			$source->add_tag_value(clone_name => $self->{_assembly}->{clone_name});
			$source->add_tag_value(end5       => $end5);
			$source->add_tag_value(end3       => $end3);
			$source->add_tag_value(chromosome => $self->{_assembly}->{chromosome});
			$source->add_tag_value(strand     => ( $strand == 1 ? 'positive' : 'negative' ));

			$line = $self->_readline();
		} else {
			$self->throw("Invalid Coordset");
		}

		if($line =~ /<MODEL[^>]*>/o) {
			do {
				$self->_pushback($line);
				$self->_process_model($tu, $end5, $end3);
				$line = $self->_readline();
			} while($line =~ /<MODEL[^>]*>/o);
			$self->_pushback($line);
			$line = $self->_readtag();
		} else {
			$self->throw("Expected <MODEL> not found");
		}
		
		if($line =~ /<TRANSCRIPT_SEQUENCE>/o) {
			my @chunks;
			$line = $self->_readline();
			while ($line =~ /^\s*([ACGT]+)\s*$/o) {
				push( @chunks, $1 );
				$line = $self->_readline();
			}
			#	$line = $self->_readline();
		}
		
		if($line =~ /<GENE_EVIDENCE>/o) {
			$line = $self->_readtag();
		}
		
		while($line =~ /<URL[^>]*>[^<]*<\/URL>/o) {
			$line = $self->_readtag();
		}
		
		if($line =~ /<\/TU>/o) {
			push(@{$self->{_sequences}}, $tu);
			return;
		} else {
			$self->throw("Expected </TU> not found: $line");
		}
	} catch Bio::Root::OutOfRange with {
		my $E = shift;
		$self->warn(sprintf("One sub location of a sequence is invalid near line $.\: %s", $E->text()));
		$line = $self->_readline() until $line =~ /<\/TU>/o;
		return;
	};
}

sub _process_gene_info
{
	my($self, $tu) = @_;
	my $line = $self->_readline();

	$self->throw("Invalid Gene Info: $line") if $line !~ /<GENE_INFO>/o;
	$line = $self->_readline();

	if($line =~ /<LOCUS>\s*([\w\.]+)\s*<\/LOCUS>/o) {
		$tu->accession_number($1);
		$tu->add_secondary_accession($1);
		$line = $self->_readline();
	} elsif( $line =~ /<LOCUS>.*<\/LOCUS>/o) {
		# We should throw an error, but TIGR doesn't alwasy play
		# nice with adhering to their dtd
		$line = $self->_readtag();
	} else {
		#$self->throw("Invalid Locus: $line");
	}

	if($line =~ /<ALT_LOCUS>\s*([\w\.]+)\s*<\/ALT_LOCUS>/o) {
		$tu->accession_number($1);
		$tu->add_secondary_accession($1);
		$line = $self->_readline();
	}

	if($line =~ /<PUB_LOCUS>\s*([\w\.]+)\s*<\/PUB_LOCUS>/o) {
		$tu->accession_number($1);
		$tu->add_secondary_accession($1);
		$line = $self->_readtag();
	} elsif( $line =~ /<PUB_LOCUS>.*<\/PUB_LOCUS>/o) {
		$line = $self->_readtag();
#		$self->throw("Invalid Pub_Locus");
	}

	if($line =~ /<GENE_NAME.*>.*<\/GENE_NAME>/o) {
		# Skip the GENE_NAME
		$line = $self->_readtag();
	}

	if(my($attr, $value) = ($line =~ /<COM_NAME([^>]*)>([^>]+)<\/COM_NAME>/o)) {
		#%attribs = ($attr =~ /(\w+)\s*=\s+"(.*?)"/og);
		#$geneinfo->{'CURATED'} = $attribs{CURATED};
		#$geneinfo->{IS_PRIMARY} = $attribs{IS_PRIMARY}
		# TODO: add a tag on sources for curated
		$tu->desc($value);
		$line = $self->_readtag();
	} else {
		$self->throw("invalid com_name: $line");
	}

	while($line =~ /<COMMENT>([^<]+)<\/COMMENT>/o) {
		my $comment = Bio::Annotation::Comment->new(
			-text => $1
		);
		$tu->annotation()->add_Annotation('comment', $comment);
		$line = $self->_readtag();
	}

	while($line =~ /<PUB_COMMENT>([^<]+)<\/PUB_COMMENT>/o) {
		my $comment = Bio::Annotation::Comment->new(
			-text => $1
		);
		$tu->annotation()->add_Annotation('comment', $comment);
		$line = $self->_readtag();
	}

	if($line =~ /<EC_NUM>([\w\-\\\.]+)<\/EC_NUM>/o) {
		#$geneinfo->{'EC_NUM'} = $1;
		$line = $self->_readtag();
	}

	if($line =~ /<GENE_SYM>\s*([^<]+)\s*<\/GENE_SYM>/o) {
		#$tu->add_secondary_accession($1);
		$line = $self->_readtag();
	}

	if($line =~ /<IS_PSEUDOGENE>([^>]+)<\/IS_PSEUDOGENE>/o) {
		#$geneinfo->{'IS_PSEUDOGENE'} = $1;
		$line = $self->_readtag();
	} else {
		$self->throw("invalid is_pseudogene: $line");
	}

	if($line =~ /<FUNCT_ANNOT_EVIDENCE/o) {
		$line = $self->_readtag();
	}

	if($line =~ /<DATE>([^>]+)<\/DATE>/o) {
		#$geneinfo->{'DATE'} = $1;
		$line = $self->_readtag();
	}

	while($line =~ /<GENE_ONTOLOGY>/o) {
		# Get the source tag
		my($source) = grep { $_->primary_tag() eq 'source' } $tu->get_SeqFeatures();

		my @ids = ( $line =~ /(<GO_ID.*?<\/GO_ID>)/gso);
		foreach my $go (@ids) {
			my($assignment) = ($go =~ /<GO_ID\s+ASSIGNMENT\s+=\s+"GO:(\d+)">/os);
			my($term)       = ($go =~ /<GO_TERM>([^<]+)<\/GO_TERM>/os);
			my($type)       = ($go =~ /<GO_TYPE>([^<]+)<\/GO_TYPE>/os);
			# TODO: Add GO annotation
			if(defined $type and defined $assignment and defined $term) {
				# Add the GO Annotation
				$source->add_tag_value(
				GO => "ID: $assignment; Type: $type; $term"
				);
			}
		}
		$line = $self->_readtag();
	}
	
	if($line =~ /<\/GENE_INFO/o) {
		return;
	}

	$self->throw("unexpected end of gene_info");
}

sub _build_location
{
	my($self, $end5, $end3, $length, $cs) = @_;
	
	# Find the start and end of the location
	# relative to the sequence.
	my $start = abs( $end5 - $cs->{end5} ) + 1;
	my $end   = abs( $end5 - $cs->{end3} ) + 1;

	# Do some bounds checking:
	if( $start < 1 ) {
		throw Bio::Root::OutOfRange(
			-text => "locations' start( $start) must be >= 1"
		);
	} elsif( $end > $length ) {
		throw Bio::Root::OutOfRange(
			-text => "locations' end( $end ) must be <= length( $length )"
		);
	} elsif( $start > $end ) {
		throw Bio::Root::OutOfRange(
			-text => "locations' start ( $start ) must be < end ( $end ) $end5, $end3, $cs->{end5}, $cs->{end3}"
		);
	}

	return Bio::Location::Simple->new( -start => $start, -end => $end, -strand => 1 );
}

sub _process_model
{
	my($self, $tu, $end5, $end3) = @_;
	my $line;
	my( $source ) = grep { $_->primary_tag() eq 'source' } $tu->get_SeqFeatures();
	my $model = Bio::SeqFeature::Generic->new(
		-source_tag  => 'TIGR',
		-primary_tag => 'MODEL',
	);

	$line = $self->_readline();
	if($line !~ /<MODEL ([^>]+)>/o) {
		$self->throw("Invalid Model: $line")
	}
	my %attribs = ($1 =~ /(\w+)\s*=\s*"([^"]*)"/og);
	#$model->{'CURATED'} = $attribs{'CURATED'};
	# TODO: Add tag to model
	$line = $self->_readline();

	if($line =~ /<FEAT_NAME>\s*([\w\.]+)\s*<\/FEAT_NAME>/o) {
		$model->add_tag_value( feat_name => $1 );
		$tu->add_secondary_accession($1);
		$line = $self->_readline();
	} else {
		$self->throw("Invalid Feature Name: $line");
	}

	if($line =~ /<PUB_LOCUS>\s*([\w\.]+)\s*<\/PUB_LOCUS>/o) {
		$model->add_tag_value( pub_locus => $1 );
		$tu->add_secondary_accession($1);
		$line = $self->_readline();
	} else {
#		$self->throw("Invalid Pub_Locus: $line");
	}

	if($line =~ /<CDNA_SUPPORT>/o) {
		$self->_pushback($line);
		$self->_process_cdna_support( $model );
		$line = $self->_readline();
	}

	while($line =~ /<CHROMO_LINK>([^>]+)<\/CHROMO_LINK>/o) {
		$model->add_tag_value( chromo_link => $1 );
		$line = $self->_readline();
	} 

	if($line =~ /<DATE>([^>]+)<\/DATE>/o) {
		$line = $self->_readline();
	} else {
		$self->throw("Invalid Date: $line");
	}

	if($line =~ /<COORDSET>/o) {
		$self->_pushback($line);
		my $cs = $self->_process_coordset();
		my $loc = $self->_build_location($end5, $end3, $tu->length(), $cs);
		
		$model->start( $loc->start() );
		$model->end(   $loc->end()   );
		$line = $self->_readline();
	} else {
		$self->throw("Invalid Coordset: $line");
	}

	my $exon = Bio::SeqFeature::Generic->new(
		-source_tag  => 'TIGR',
		-primary_tag => 'EXON',
		-location => Bio::Location::Split->new(),
		-tags => [ locus => $tu->accession_number() ],
	);
	$exon->add_tag_value( model => $model->get_tag_values('feat_name') );

	my $cds  = Bio::SeqFeature::Generic->new(
		-source_tag  => 'TIGR',
		-primary_tag => 'CDS',
		-location => Bio::Location::Split->new(),
		-tags => [ locus => $tu->accession_number() ],
	);
	$cds->add_tag_value( model => $model->get_tag_values('feat_name') );
	my $utr = [];

	if($line =~ /<EXON>/o) {
		do {
			$self->_pushback($line);
			$self->_process_exon( $tu, $exon, $cds, $utr, $end5, $end3 );
			$line = $self->_readline();
		} while($line =~ /<EXON>/o);
	} else {
		$self->throw("Required <EXON> missing");
	}
	
	until($line =~ /<\/MODEL>/o) {
		$line = $self->_readline();
	}


	$_->add_tag_value( model => $model->get_tag_values('feat_name') )
		foreach @$utr;

	# Add the model, EXONs, CDS, and UTRs
	$tu->add_SeqFeature($model) if $model and $model->start() >= 1;
	$tu->add_SeqFeature($exon)  if $exon  and scalar($exon->location()->each_Location()) >= 1;
	$tu->add_SeqFeature($cds)   if $cds   and scalar($cds->location()->each_Location()) >= 1;
	$tu->add_SeqFeature(@$utr);

	return;
}

sub _process_cdna_support
{
	my($self, $model) = @_;
	my $line = $self->_readline();

	if($line !~ /<CDNA_SUPPORT>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_cdna_support called ",
		             "but no <CDNA_SUPPORT> in the stream");
	}

	$line = $self->_readline();

	while( $line =~ /<ACCESSION([^>]+)>(.*)<\/ACCESSION>/o) {
		# Save the text
		my $desc = $2;
		
		# Get the element's attributes
		my %attribs = ($1 =~ /(\w+)\s*=\s*"([^"]*)"/og);

		# Add the tag to the model
		$model->add_tag_value(
			cdna_support => "DBXRef: $attribs{DBXREF}; $desc"
		);

		$line = $self->_readline();
	}

	if( $line =~ /<\/CDNA_SUPPORT>/o) {
		return;
	}
	$self->throw("reached end of _process_cdna_support");
}


sub _process_exon
{
	my($self, $tu, $exon, $cds, $utr, $end5, $end3 ) = @_;
	my $line = $self->_readline();

	if($line !~ /<EXON>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_exon called ",
		             "but no <EXON> in the stream");
	}

	$line = $self->_readtag();
	if($line =~ /<FEAT_NAME>([^<]+)<\/FEAT_NAME>/o) {
		# Ignore
		$line = $self->_readtag();
	} else {
		$self->throw("Required <FEAT_NAME> missing");
	}

	if($line =~ /<DATE>([^<]+)<\/DATE>/o) {
		# Ignore
		$line = $self->_readtag();
	} else {
		$self->throw("Required <DATE> missing");
	}

	if($line =~ /<COORDSET>/o) {
		$self->_pushback($line);
		my $cs = $self->_process_coordset();
		my $loc = $self->_build_location($end5, $end3, $tu->length(), $cs);
		$exon->location()->add_sub_Location($loc);
		$line = $self->_readline();
	} else {
		$self->throw("Required <COORDSET> missing");
	}

	if($line =~ /<CDS>/o) {
		$self->_pushback($line);
		$self->_process_cds($tu, $end5, $end3, $cds);
		$line = $self->_readline();
	}

	if($line =~ /<UTRS>/o) {
		$self->_pushback($line);
		$self->_process_utrs($tu, $end5, $end3, $utr);
		$line = $self->_readline();
	}

	if($line =~ /<\/EXON>/o) {
		return;
	}

	$self->throw("Reached End of Bio::SeqIO::tigr::_process_exon");
}

sub _process_cds
{
	my($self, $tu, $end5, $end3, $cds) = @_;
	my $line = $self->_readline();

	if($line !~ /<CDS>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_cda_support called ",
		             "but no <CDS> in the stream");
	}
	
	$line = $self->_readtag();
	if($line =~ /<FEAT_NAME>([^<]+)<\/FEAT_NAME>/o) {
		#$cds->{'FEAT_NAME'} = $1;
		$line = $self->_readtag();
	} else {
		$self->throw("Required <FEAT_NAME> missing");
	}

	if($line =~ /<DATE>([^<]+)<\/DATE>/o) {
		#$cds->{'DATE'} = $1;
		$line = $self->_readtag();
	} else {
		$self->throw("Required <DATE> missing");
	}

	if($line =~ /<COORDSET>/o) {
		$self->_pushback($line);
		my $cs = $self->_process_coordset();
		my $loc = $self->_build_location($end5, $end3, $tu->length(), $cs);
		$cds->location()->add_sub_Location($loc);
		$line = $self->_readline();
	} else {
		$self->throw("Required <COORDSET> missing");
	}

	if($line =~ /<\/CDS>/o) {
		return;
	}

	$self->throw("Reached onf of Bio::SeqIO::tigr::_process_cds");
}

sub _process_utrs
{
	my($self, $tu, $end5, $end3, $utrs) = @_;
	my $line = $self->_readline();

	if($line !~ /<UTRS/o) {
		$self->throw("Bio::SeqIO::tigr::_process_utrs called but no ",
		             "<UTRS> found in stream");
	}

	$line = $self->_readline();
	while($line !~ /<\/UTRS>/o) {
		$self->_pushback($line);
		if($line =~ /<LEFT_UTR>/o) {
			$self->_process_left_utr($tu, $end5, $end3, $utrs);
		} elsif ($line =~ /<RIGHT_UTR>/o) {
			$self->_process_right_utr($tu, $end5, $end3, $utrs);
		} elsif ($line =~ /<EXTENDED_UTR>/o) {
			$self->_process_ext_utr($tu, $end5, $end3, $utrs);
		} else {
			$self->throw("Unexpected tag");
		}
	
		$line = $self->_readline();
	}

	if($line =~ /<\/UTRS>/o) {
		return $utrs;
	}
	$self->throw("Reached end of Bio::SeqIO::tigr::_process_utrs");
}

sub _process_left_utr
{
	my($self, $tu, $end5, $end3, $utrs) = @_;
	my $line = $self->_readline();
	my $coordset;

	if($line !~ /<LEFT_UTR>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_left_utr called but ",
		             "no <LEFT_UTR> found in stream");
	}

	$line = $self->_readtag();
	if($line =~ /<COORDSET>/o) {
		$self->_pushback($line);
		my $cs = $self->_process_coordset();
		my $loc = $self->_build_location($end5, $end3, $tu->length(), $cs);

		push(@$utrs, Bio::SeqFeature::Generic->new(
		        -source_tag  => 'TIGR',
				-primary_tag => 'LEFT_UTR',
				-strand => 1,
				-start => $loc->start(),
				-end   => $loc->end()
		));

		$line = $self->_readline();
	} else {
		$self->throw("Required <COORDSET> missing");
	}

	if($line =~ /<\/LEFT_UTR>/o) {
		return;
	}
	$self->throw("Reached end of Bio::SeqIO::tigr::_process_left_utr");
}

sub _process_right_utr
{
	my($self, $tu, $end5, $end3, $utrs) = @_;
	my $line = $self->_readline();
	my $coordset;

	if($line !~ /<RIGHT_UTR>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_right_utr called but ",
		             "no <RIGHT_UTR> found in stream");
	}

	$line = $self->_readtag();
	if($line =~ /<COORDSET>/o) {
		$self->_pushback($line);
		$coordset = $self->_process_coordset();
		$self->_pushback($line);
		my $cs = $self->_process_coordset();
		my $loc = $self->_build_location($end5, $end3, $tu->length(), $cs);

		push(@$utrs, Bio::SeqFeature::Generic->new(
		        -source_tag  => 'TIGR',
				-primary_tag => 'RIGHT_UTR',
				-strand => 1,
				-start => $loc->start(),
				-end   => $loc->end()
		));

		$line = $self->_readline();
	} else {
		$self->throw("Required <COORDSET> missing");
	}

	if($line =~ /<\/RIGHT_UTR>/o) {
		return $coordset;
	}
	$self->throw("Reached end of Bio::SeqIO::tigr::_process_right_utr");
}

sub _process_ext_utr
{
	my($self, $tu, $end5, $end3, $utrs) = @_;
	my $line = $self->_readline();
	my $coordset;

	if($line !~ /<EXTENDED_UTR>/o) {
		$self->throw("Bio::SeqIO::tigr::_process_ext_utr called but ",
		             "no <EXTENDED_UTR> found in stream");
	}

	$line = $self->_readtag();
	if($line =~ /<COORDSET>/o) {
		$self->_pushback($line);
		my $cs = $self->_process_coordset();
		my $loc = $self->_build_location($end5, $end3, $tu->length(), $cs);

		push(@$utrs, Bio::SeqFeature::Generic->new(
		        -source_tag  => 'TIGR',
				-primary_tag => 'EXTENDED_UTR',
				-strand => 1,
				-start => $loc->start(),
				-end   => $loc->end()
		));

		$line = $self->_readline();
	} else {
		$self->throw("Required <COORDSET> missing");
	}

	if($line =~ /<\/EXTENDED_UTR>/o) {
		return $coordset;
	}
	$self->throw("Reached end of Bio::SeqIO::tigr::_process_ext_utr");
}

sub _readtag
{
	my($self) = @_;
	my $line = $self->_readline();
	chomp($line);

	my $tag;
	if(($tag) = ($line =~ /^[^<]*<\/(\w+)/o)) {
		$self->_pushback($1) if $line =~ /<\/$tag>(.+)$/;
		return "</$tag>";
	}
 
	until(($tag) = ($line =~ /<(\w+)[^>]*>/o)) {
		$line = $self->_readline();
		chomp $line;
	}

	until($line =~ /<\/$tag>/) {
		$line .= $self->_readline();
	}

	if(my ($val) = ($line =~ /(<$tag.*>.*?<\/$tag>)/s)) {
		if($line =~ /<\/$tag>\s*(\w+[\s\w]*?)\s*$/s) {
			$self->_pushback($1)
		}
		return $val;
	}
	$self->throw("summerror");
}

sub _readline
{
	my($self) = @_;
	my $line;
	do {
		$line = $self->SUPER::_readline();
	} while(defined($line) and $line =~ /^\s*$/o);

	return $line;
}

sub throw
{
	my($self, @s) = @_;
	my $string = "[$.]" . join('', @s);
	$self->SUPER::throw($string);
}

1;
