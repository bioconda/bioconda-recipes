#
# BioPerl module for Bio::SeqIO::game::gameWriter
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Sheldon McKay <mckays@cshl.edu>
#
# You may distribute this module under the same terms as perl itself
#

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::game::gameWriter -- a class for writing game-XML

=head1 SYNOPSIS

  use Bio::SeqIO;

  my $in  = Bio::SeqIO->new( -format => 'genbank',
                             -file => 'myfile.gbk' );
  my $out = Bio::SeqIO->new( -format => 'game',
                             -file => 'myfile.xml' );

  # get a sequence object
  my $seq = $in->next_seq;

  #write it in GAME format
  $out->write_seq($seq);

=head1 DESCRIPTION

Bio::SeqIO::game::gameWriter writes GAME-XML (v. 1.2) that is readable
by Apollo.  It is best not used directly.  It is accessed via
Bio::SeqIO.

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this and other
Bioperl modules. Send your comments and suggestions preferably to one
of the Bioperl mailing lists.

Your participation is much appreciated.

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
of the bugs and their resolution. Bug reports can be submitted via the
web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Sheldon McKay

Email mckays@cshl.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

package Bio::SeqIO::game::gameWriter;

use strict;
use IO::String;
use XML::Writer;
use Bio::SeqFeature::Generic;
use Bio::SeqFeature::Tools::Unflattener;

use base qw(Bio::SeqIO::game::gameSubs);

=head2 new

 Title   : new
 Usage   : my $writer = Bio::SeqIO::game::gameWriter->new($seq);
 Function: constructor method for gameWriter 
 Returns : a game writer object 
 Args    : a Bio::SeqI implementing object
           optionally, an argument to set map_position to on.
           ( map => 1 ).  This will create a map_position elemant
           that will cause the feature coordinates to be remapped to
           a parent seqeunce.  A sequence name in the format seq:xxx-xxx
           is expected to determine the offset for the map_position.
           The default behavior is to have features mapped relative to 
           the sequence contained in the GAME-XML file

=cut

sub new {
    my ($caller, $seq, %arg) = @_;
    my $class = ref($caller) || $caller;
    my $self = bless ( { seq => $seq }, $class );

    # make a <map_position> element only if requested 
    $self->{map} = 1 if $arg{map};
    $self->{anon_set_counters} = {}; #counters for numbering anonymous result and feature sets
    return $self;
}

=head2 write_to_game

 Title   : write_to_game
 Usage   : $writer->write_to_game
 Function: writes the sequence object to game-XML 
 Returns : xml as a multiline string
 Args    : none

=cut

sub write_to_game {
    my $self   = shift;
    my $seq    = $self->{seq};
    my @feats  = $seq->remove_SeqFeatures;

    # intercept nested features 
    my @nested_feats = grep { $_->get_SeqFeatures } @feats;
    @feats = grep { !$_->get_SeqFeatures } @feats;
    map { $seq->add_SeqFeature($_) } @feats;

# NB -- Maybe this belongs in Bio::SeqFeatute::Tools::Unflattener

#    # intercept non-coding RNAs and transposons with contained genes
#    # GAME-XML has these features as top level annotations which contain
#    # gene elements
#    my @gene_containers = ();
     
#    for ( @feats ) {
#	if ( $_->primary_tag =~ /[^m]RNA|repeat_region|transpos/ && 
#	     $_->has_tag('gene') ) {
#	    my @genes = $_->get_tag_values('gene');
#	    my ($min, $max) = (10000000000000,-10000000000000);
#	    for my $g ( @genes ) {
#		my $gene;
#		for my $item ( @feats ) {
#		    next unless $item->primary_tag eq 'gene';
#		    my ($n) = $item->get_tag_values('gene');
#		    next unless $n =~ /$g/;
#		    $gene = $item;
#		    last;
#		}
#		next unless $gene && ref $gene;
#		$max = $gene->end if $gene->end > $max;
#		$min = $gene->start if $gene->start < $min;
#	    }
#	    
#	    push @gene_containers, $_ if $_->length >= ($max - $min);
#	}
#	else {
#	    $seq->add_SeqFeature($_);
#	}
#    }
	
    # unflatten 
    my $uf = Bio::SeqFeature::Tools::Unflattener->new;
    $uf->unflatten_seq( -seq => $seq, use_magic => 1 );
    
    # rearrange snRNA and transposon hierarchies
    # $self->_rearrange_hierarchies($seq, @gene_containers);

    # add back nested feats
    $seq->add_SeqFeature( $_ ) foreach @nested_feats;
    
    my $atts  = {};
    my $xml = '';
    
    # write the XML to a string
    my $xml_handle = IO::String->new($xml);
    my $writer = XML::Writer->new(OUTPUT      => $xml_handle,
				  DATA_MODE   => 1,
				  DATA_INDENT => 2,
				  NEWLINE     => 1
				  );
    $self->{writer} = $writer;
#    $writer->xmlDecl("UTF-8");
#    $writer->doctype("game", 'game', "http://www.fruitfly.org/annot/gamexml.dtd.txt");
    $writer->comment("GAME-XML generated by Bio::SeqIO::game::gameWriter");
    $writer->comment("Created " . localtime);
    $writer->comment('Questions: mckays@cshl.edu');
    $writer->startTag('game', version => 1.2);
    
    my @sources = grep { $_->primary_tag =~ /source|origin|region/i } $seq->get_SeqFeatures;
    
    for my $source ( @sources ) {
	next unless $source->length == $seq->length;
	for ( qw{ name description db_xref organism md5checksum } ) {
	    if ( $source->has_tag($_) ) {
		$self->{has_organism} = 1 if /organism/;
		($atts->{$_}) = $source->get_tag_values($_);
	    }
	}
    }
    

    #set a name in the attributes if none was given
    $atts->{name} ||= $seq->accession_number ne 'unknown'
      ? $seq->accession_number : $seq->display_name;

    $self->_seq($seq, $atts);
    
    # make a map_position element if req'd
    if ( $self->{map} ) {
	my $seqtype;
	if ( $atts->{mol_type} || $seq->alphabet ) {
	    $seqtype = $atts->{mol_type} || $seq->alphabet;
	}
	else {
	    $seqtype = 'unknown';
	}    
	
	$writer->startTag(
			  'map_position', 
			  seq => $atts->{name},
			  type => $seqtype
			  );
	
	my ($arm, $start, undef, $end) = $atts->{name} =~ /(\S+):(-?\d+)(\.\.|-)(-?\d+)/;
	$self->_element('arm', $arm) if $arm;
	$self->_span($start, $end);
	$writer->endTag('map_position');
    }

    for ( $seq->top_SeqFeatures ) {

      if($_->isa('Bio::SeqFeature::Computation')) {
	$self->_comp_analysis($_);
      }
      else {
        # if the feature has subfeatures, we will assume it is a gene
	# (hope this is safe!)
	if ( $_->get_SeqFeatures ) {
	  $self->_write_gene($_);
	} else {
	  # non-gene stuff only
	  next if $_->primary_tag =~ /CDS|mRNA|exon|UTR/;
	  $self->_write_feature($_);
	}
      }
    }    
    
    $writer->endTag('game');
    $writer->end;
    $xml;
}

=head2 _rearrange_hierarchies

 Title   : _rearrange_hierarchies
 Usage   : $self->_rearrange_hierarchies($seq)
 Function: internal method to rearrange gene containment hierarchies
           so that snRNA or transposon features contain their genes
           rather than the other way around
 Returns : nothing
 Args    : a Bio::RichSeq object
 Note    : Not currently used, may be removed

=cut

sub _rearrange_hierarchies { #renamed to not conflict with Bio::Root::_rearrange
    my ($self, $seq, @containers) = @_;
    my @feats   = $seq->remove_SeqFeatures;
    my @genes   = grep { $_->primary_tag eq 'gene' } @feats;
    my @addback = grep { $_->primary_tag ne 'gene' } @feats;
    
    for ( @containers ) {
	my @has_genes = $_->get_tag_values('gene');
	for my $has_gene ( @has_genes ) {
	    for my $gene ( @genes ) {
		next unless $gene;
		my ($gname) = $gene->get_tag_values('gene');
		if ( $gname eq $has_gene ) {
		    $_->add_SeqFeature($gene);
		    undef $gene;
		}
	    }
	}
    }    
   
    push @addback, (@containers, grep { defined $_ } @genes );
    $seq->add_SeqFeature($_) foreach @addback;
}


=head2 _write_feature

 Title   : _write_feature
 Usage   : $seld->_write_feature($feat, 1)
 Function: internal method for writing generic features as <annotation> elements
 Returns : nothing
 Args    : a Bio::SeqFeature::Generic object and an optional flag to write a
           bare feature set with no annotation wrapper

=cut

sub _write_feature {
    my ($self, $feat, $bare) = @_;
    my $writer = $self->{writer};
    my $id;

    for ( 'standard_name', $feat->primary_tag, 'ID' ) {
	$id = $self->_find_name($feat, $_ );
	last if $id;
    } 

    $id ||= $feat->primary_tag . '_' . ++$self->{$feat->primary_tag}->{id};

    unless ( $bare ) {
	$writer->startTag('annotation', id => $id); 
	$self->_element('name', $id);
	$self->_element('type', $feat->primary_tag);
    }

    $writer->startTag('feature_set', id => $id);
    $self->_element('name', $id);
    $self->_element('type', $feat->primary_tag);
    $self->_render_tags( $feat,
			 \&_render_date_tags,
			 \&_render_comment_tags,
			 \&_render_tags_as_properties
		       );
    $self->_feature_span($id, $feat);
    $writer->endTag('feature_set');
    $writer->endTag('annotation') unless $bare;
}

=head2 _write_gene

 Title   : _write_gene
 Usage   : $self->_write_gene($feature)
 Function: internal method for rendering gene containment hierarchies into 
           a nested <annotation> element 
 Returns : nothing
 Args    : a nested Bio::SeqFeature::Generic gene feature
 Note    : A nested gene hierarchy (gene->mRNA->CDS->exon) is expected.  If other gene 
           subfeatures occur as level one subfeatures (same level as mRNA subfeats) 
           an attempt will be made to link them to transcripts via the 'standard_name'
           qualifier

=cut

sub _write_gene {
    my ($self, $feat) = @_;
    my $writer = $self->{writer};
    my $str = $feat->strand;
    my $id = $self->_find_name($feat, 'standard_name')
          || $self->_find_name($feat, 'gene')
	  || $self->_find_name($feat, $feat->primary_tag)
	  || $self->_find_name($feat, 'locus_tag') 
	  || $self->_find_name($feat, 'symbol')
          || $self->throw(<<EOM."Feature name was: '".($feat->display_name || 'not set')."'");
Could not find a gene/feature ID, feature must have a primary tag or a tag
with one of the names: 'standard_name', 'gene', 'locus_tag', or 'symbol'.
EOM
    my $gid = $self->_find_name($feat, 'gene') || $id;

    $writer->startTag('annotation', id => $id);
    $self->_element('name', $gid);
    $self->_element('type', $feat->primary_tag);
    $self->_render_tags( $feat,
			 \&_render_date_tags,
			 \&_render_dbxref_tags,
			 \&_render_comment_tags,
			 \&_render_tags_as_properties,
		       );
    
    my @genes;
    
    if ( $feat->primary_tag eq 'gene' ) {
	@genes = ($feat);
    }
    else {
	# we are in a gene container; gene must then be one level down
	@genes = grep { $_->primary_tag eq 'gene' } $feat->get_SeqFeatures;
    }

    for my $g ( @genes ) {
	my $id ||= $self->_find_name($g, 'standard_name')
               || $self->_find_name($g, 'gene') 
	       || $self->_find_name($feat, 'locus_tag')
               || $self->_find_name($feat, 'symbol')
               || $self->throw("Could not find a gene ID");
	my $gid ||= $self->_find_name($g, 'gene') || $self->_find_name($g);

	$writer->startTag('gene', association => 'IS');
        $self->_element('name', $gid);
        $writer->endTag('gene');

        my $proteins;
	my @mRNAs = grep { $_->primary_tag =~ /mRNA|transcript/ } $g->get_SeqFeatures;
	my @other_stuff = grep { $_->primary_tag !~ /mRNA|transcript/ } $g->get_SeqFeatures;
	my @variants = ('A' .. 'Z');

	for my $mRNA (@mRNAs) {
	    my ($sn, @units);
            # if the mRNA is a generic transcript, it must be a non-spliced RNA gene
            # Make a synthetic exon to help build a hierarchy.  We have to assume that
            # the location is not segmented (otherwise it should be a mRNA)
	    if ( $mRNA->primary_tag eq 'transcript') {
		my $exon = Bio::SeqFeature::Generic->new ( -primary => 'exon' );
		$exon->location($mRNA->location);
		$mRNA->add_SeqFeature($exon);
	    }

            # no subfeats? Huh? revert to generic feature
	    unless ( $mRNA->get_SeqFeatures ) {
		$self->_write_feature($mRNA, 1); # 1 flag writes the bare feature
                                                 # with no annotation wrapper
		next;
	    }

	    my $name = $self->_find_name($mRNA, $mRNA->primary_tag) 
                     || $self->_find_name($mRNA, 'standard_name');

	    my %attributes;
            my ($cds) = grep { $_->primary_tag eq 'CDS' } $mRNA->get_SeqFeatures;

	    # make sure we have the right CDS for alternatively spliced genes
	    # This is meant to deal with sequences from flattened game annotations, 
	    # where both the mRNA and CDS have split locations
	    if ( $cds && @mRNAs > 1 && $name ) {
		$cds = $self->_check_cds($cds, $name);
	    }
	    elsif ( $cds && @mRNAs == 1 ) {
		# The mRNA/CDS pairing must be right. Get the transcript name from the CDS
		if ( $cds->has_tag('standard_name') ) {
		    ($name) = $cds->get_tag_values('standard_name');
                }
	    }
	    
	    if ( !$name ) {
		# assign a name to the transcript if it has no 'standard_name' binder
		$name = $id . '-R' . (shift @variants);
	    }

            my $pname;

	    if ( $cds ) {
		($sn) = $cds->get_tag_values('standard_name')
		    if $cds->has_tag('standard_name');
		($sn) ||= $cds->get_tag_values('mRNA')
		   if $cds->has_tag('mRNA');

		# the protein needs a name
		my $psn = $self->protein_id($cds, $sn);
                $self->{curr_pname} = $psn;

		# the mRNA need to know the name of its protein
		unless ( $feat->has_tag('protein_id') ) {
		    $feat->add_tag_value('protein_id', $psn);
		}

                # define the translation offset
		my ($c_start, $c_end);
		if ( $cds->has_tag('codon_start') ){
		    ($c_start) = $cds->get_tag_values('codon_start');
		    $cds->remove_tag('codon_start');
		}
		else {
		    $c_start = 1;
		}
		my $cs  = Bio::SeqFeature::Generic->new;
		if ( $c_start == 1 ) {
		    $c_start = $cds->strand > 0 ? $cds->start : $cds->end;
		}
		if ( $cds->strand < 1 ) {
		    $c_end = $c_start;
		    $c_start = $c_start - 2;
		}
		else {
		    $c_end = $c_start + 2;
		}
		$cs->start($c_start);
		$cs->end($c_end);
		$cs->strand($cds->strand);
		$cs->primary_tag('start_codon');
		$cs->add_tag_value( 'standard_name' => $name );
		push @units, $cs;


		if ( $cds->has_tag('problem') ) {
		    my ($val) = $cds->get_tag_values('problem');
		    $cds->remove_tag('problem');
		    $attributes{problem} = $val;
		}
		
		my ($aa) = $cds->get_tag_values('translation')
		    if $cds->has_tag('translation');
		
		if ( $aa && $psn ) {
		    $cds->remove_tag('translation');
		    my %add_seq = ();
		    $add_seq{residues} = $aa;
		    $add_seq{header} = ['seq',
					id     => $psn,
					length => length $aa,
					type   => 'aa' ];
		    
		    if ( $cds->has_tag('product_desc') ) {
			($add_seq{desc}) = $cds->get_tag_values('product_desc');
			$cds->remove_tag('product_desc');
		    }
		    
		    unless ( $add_seq{desc} && $add_seq{desc} =~ /cds_boundaries/ ) {
			my $start = $cds->start;
			my $end   = $cds->end;
			my $str   = $cds->strand;
			my $acc   = $self->{seq}->accession || $self->{seq}->display_id;
			$str = $str < 0 ? '[-]' : '';
			$add_seq{desc}  = "translation from_gene[$gid] " .
			    "cds_boundaries:(" . $acc . 
			    ":$start..$end$str) transcript_info:[$name]";
		    }
		    $self->{add_seqs} ||= [];
		    push @{$self->{add_seqs}}, \%add_seq;
		}
	    }

	    
	    $writer->startTag('feature_set', id => $name);
	    $self->_element('name', $name);
	    $self->_element('type', 'transcript');
	    $self->_render_tags($_,
				\&_render_date_tags,
				\&_render_comment_tags,
				\&_render_tags_as_properties,
			       ) for ( $mRNA, ($cds) || () );
	     
	    # any UTR's, etc associated with this transcript?
	    for my $thing ( @other_stuff ) {
		if ( $thing->has_tag('standard_name') ) {
		    my ($v)  = $thing->get_tag_values('standard_name');
		    if ( $v eq $sn ) {
			push @units, $thing;
		    }
		}
	    }
	    
	    # add the exons
	    push @units, grep { $_->primary_tag eq 'exon' } $mRNA->get_SeqFeatures;
	    @units = sort { $a->start <=> $b->start } @units;

	    my $count  = 0;
	    
	    if ( $str < 0 ) {
		@units = reverse @units;
	    }
            
	    for my $unit ( @units ) {
		if ( $unit->primary_tag eq 'exon' ) {
		    my $ename = $id;
		    $ename .= ':' . ++$count;
		    $self->_feature_span($ename, $unit);
		}
		elsif ( $unit->primary_tag eq 'start_codon' ) {
		    $self->_feature_span(($sn || $gid), $unit, $self->{curr_pname});
		}
		else {
		    my $uname = $unit->primary_tag . ":$id";
		    $self->_feature_span($uname, $unit);
		}
	    }
	    $self->{curr_pname} = '';
	    $writer->endTag('feature_set');
	}
	
	$self->{other_stuff} = \@other_stuff;
    }    
    
    $writer->endTag('annotation');

    # add the protein sequences
    for ( @{$self->{add_seqs}} ) {
	my %h = %$_;
	$writer->startTag(@{$h{header}});
	my @desc = split /\s+/, $h{desc};
	my $desc = '';
	for my $word (@desc) {
	    my ($lastline) = $desc =~ /.*^(.+)$/sm;
	    $lastline ||= '';
	    $desc .= length $lastline < 50 ? " $word " : "\n      $word ";
	}
        $self->_element('description', "\n     $desc\n    ");

	my $aa = $h{residues};
	$aa =~ s/(\w{60})/$1\n      /g;
	$aa =~ s/\n\s+$//m;
	$aa = "\n      " . $aa . "\n    ";
	$self->_element('residues', $aa);
	$writer->endTag('seq');
	$self->{add_seqs} = [];
    }
    
    # Is there anything else associated with the gene?  We have to write other
    # features as stand-alone annotations or apollo will assume they are
    # transcripts
    for my $thing ( @{$self->{other_stuff}} ) {
	next if $thing->has_tag('standard_name');
	$self->_write_feature($thing);
    }
    $self->{other_stuff} = [];
}


=head2 _check_cds

 Title   : _check_cds
 Usage   : $self->_check_cds($cds, $name)
 Function: internal method to check if the CDS associated with an mRNA is
           the correct alternative splice variant
 Returns : a Bio::SeqFeature::Generic CDS object
 Args    : the CDS object plus the transcript\'s 'standard_name'
 Note    : this method only works if alternatively spliced transcripts are bound
           together by a 'standard_name' or 'mRNA' qualifier.  If none is present, 
           we will hope that the exons were derived from a segmented RNA or a CDS 
           with no associated mRNA feature.  Neither of these two cases would be 
           confounded by alternative splice variants.

=cut


sub _check_cds {
    my ($self, $cds, $name) = @_;
    my $cname = $self->_find_name( $cds, 'standard_name' )
             || $self->_find_name( $cds, 'mRNA');
    
    if ( $cname ) {
	if ( $cname eq $name ) {
	    return $cds;
	}
	else {
	    my @CDS = grep { $_->primary_tag eq 'CDS' } @{$self->{feats}};
	    for ( @CDS ) {
		my ($sname) = $_->_find_name( $_, 'standard_name' )
		           || $_->_find_name( $_, $_->primary_tag );
		return $_ if $sname eq $name;
	    }
	    return '';
	}
    }
    else {
	return $cds;
    }

}

=head2 _comp_analysis

  Usage:
  Desc :
  Ret  :
  Args :
  Side Effects:
  Example:

=cut

sub _comp_analysis {
  my ($self, $feat) = @_;
  my $writer = $self->{writer};

  $writer->startTag('computational_analysis');
  $self->_element('program', $feat->program_name || 'unknown program');
  $self->_element('database', $feat->database_name) if $feat->database_name;
  $self->_element('version', $feat->program_version) if $feat->program_version;
  $self->_element('type', $feat->primary_tag) if $feat->primary_tag;
  $self->_render_tags($feat,
		      \&_render_date_tags,
		      \&_render_tags_as_properties,
		     );
  $self->_comp_result($feat);
  $writer->endTag('computational_analysis');
}

=head2 _comp_result

  Usage:
  Desc : recursively render a feature and its subfeatures as
         <result_set> and <result_span> elements
  Ret  : nothing meaningful
  Args : a feature

=cut


sub _comp_result {
  my ($self,$feat) = @_;

  #check that all our subfeatures have the same strand
  

  #write result sets for things that have subfeatures, or things
  #that have some tags
  if( my @subfeats = $feat->get_SeqFeatures or $feat->get_all_tags ) {
    my $writer = $self->{writer};
    $writer->startTag('result_set',
		      ($feat->can('computation_id') && defined($feat->computation_id))
		        ? (id => $feat->computation_id) : ()
		     );
    my $fakename = $feat->primary_tag || 'no_name';
    $self->_element('name', $feat->display_name || ($fakename).'_'.++$self->{anon_result_set_counters}{$fakename} );
    $self->_seq_relationship('query', $feat);
    $self->_render_tags($feat,
			\&_render_output_tags
		       );
    for (@subfeats) { #render the subfeats, if any
      $self->_comp_result($_);
    }
    $self->_comp_result_span($feat); #also have a span to hold this info
    $writer->endTag('result_set');
  } else {
    #just write result spans for simple things
    $self->_comp_result_span($feat);
  }
}

=head2 _comp_result_span

  Usage: _comp_result_span('foo12',$feature);
  Desc : write GAME XML for a Bio::SeqFeature::Computation feature
         that has no subfeatures
  Ret  : nothing meaningful
  Args : name for this span (some kind of identifier),
         SeqFeature object to put into this span
  Side Effects:
  Example:

=cut

sub _comp_result_span {

  my ($self, $feat) = @_;
  my $writer = $self->{writer};

  $writer->startTag('result_span',
		    ($feat->can('computation_id') && defined($feat->computation_id) ? (id => $feat->computation_id) : ())
		   );
  $self->_element('name', $feat->display_name) if $feat->display_name;
  $self->_element('type', $feat->primary_tag) if $feat->primary_tag;
  my $has_score = $feat->can('has_score') ? $feat->has_score : defined($feat->score);
  $self->_element('score', $feat->score) if $has_score;
  $self->_render_tags($feat,
		      \&_render_output_tags
		     );
  $self->_seq_relationship('query', $feat);
  $self->_render_tags($feat,
		      \&_render_target_tags,
		     );
  $writer->endTag('result_span');
}

=head2 _render_tags

  Usage:
  Desc :
  Ret  :
  Args :
  Side Effects:
  Example:

=cut

sub _render_tags {
  my ($self,$feat,@render_funcs) = @_;

  my @tagnames = $feat->get_all_tags;

  #do a chain-of-responsibility down the allowed
  #tag handlers types for the context in which this is
  #called
  foreach my $func (@render_funcs) {
    @tagnames = $self->$func($feat,@tagnames);
  }
}

=head2 _render_output_tags

  Usage:
  Desc : print out <output> elements, with contents
         taken from the SeqFeature::Computation's 'output' tag
  Ret  : array of tag names this did not render
  Args : feature object, list of tag names to maybe render

  In game xml, only <result_span> and <result_set> elements can
  have <output> elements.

=cut

sub _render_output_tags {
  my ($self, $feat, @tagnames) = @_;
  my $writer = $self->{writer};
  my @passed_up;

  for my $tag (@tagnames) {
    if(lc($tag) eq 'output') {
      my @outputs = $feat->get_tag_values($tag);
      while(my($type,$val) = splice @outputs,0,2) {
	$writer->startTag('output');
	$self->_element('type',$type);
	$self->_element('value',$val);
	$writer->endTag('output');
      }
    }
    else {
      push @passed_up,$tag;
    }
  }
  return @passed_up;
}

=head2 _render_tags_as_properties

  Usage:
  Desc :
  Ret  : empty array
  Args : feature object, array of tag names
  Side Effects:
  Example:

  In game xml, <annotation>, <computational_analysis>,
  and <feature_set> elements can have properties.

=cut

sub _render_tags_as_properties {
  my ($self,$feat,@tagnames) = @_;

  foreach my $tag (@tagnames) {
    if( $tag ne $feat->primary_tag ) {
      $self->_property($tag,$_) for $feat->get_tag_values($tag);
    }
  }
  return ();
}

=head2 _render_comment_tags

  Usage:
  Desc :
  Ret  : names of tags that were not comment tags
  Args : feature object, tag names available for us to render
  Side Effects: writes XML
  Example:

  In game xml, <annotation> and <feature_set> elements can
  have comments.

=cut

sub _render_comment_tags {
  my ($self,$feat,@tagnames) = @_;
  my $writer = $self->{writer};
  my @passed_up;
  for my $tag ( @tagnames ) {
    if( lc($tag) eq 'comment' ) {
      for my $val ($feat->get_tag_values($tag)) {
	if ( $val =~ /=.+?;.+=/ ) {
	  $self->_unflatten_attribute('comment', $val);
	} else {
	  $writer->startTag('comment');
	  $self->_element('text', $val);
	  $writer->endTag('comment');
	}
      }
    } else {
      push @passed_up,$tag;
    }
  }
  return @passed_up;
}

=head2 _render_date_tags

  Usage:
  Desc :
  Ret  : names of tags that were not date tags
  Args : feature, list of tag names available for us to render
  Side Effects: writes XML for <date> elements
  Example:

  In game xml, <annotation>, <computational_analysis>,
  <transaction>, <comment>, and <feature_set> elements
  can have <date>s.

=cut

sub _render_date_tags {
  my ($self,$feat,@tagnames) = @_;
  my @passed_up;
  my $date;
  my %timestamp;
  foreach my $tag (@tagnames) {
    if ( lc($tag) eq 'date' ) {
      ($date) = $feat->get_tag_values($tag);
    } elsif ( lc($tag) eq 'timestamp' ) {
      ($timestamp{'timestamp'}) = $feat->get_tag_values($tag);
      #ignore timestamps, they are folded in with date elem above
    } else {
      push @passed_up,$tag;
    }
  }
  $self->_element('date', $date, \%timestamp) if defined($date);
  return @passed_up;
}

=head2 _render_dbxref_tags

  Desc : look for xref tags and render them if they are there
  Ret  : tag names that we didn't render
  Args : feature object, list of tag names to render
  Side Effects: writes a <dbxref> element if a tag with name
                matching /xref$/i is present


  In game xml, <annotation> and <seq> elements can have dbxrefs.

=cut

#TODO: can't sequences also have database xrefs?  how to find those?
sub _render_dbxref_tags {
  my ($self, $feat, @tagnames) = @_;
  my @passed_up;
  for my $tag ( @tagnames ) {                           #look through all the tags
    if( $tag =~ /xref$/i ) {                            #if they are xref tags
      my $writer = $self->{writer};
      for my $val ( $feat->get_all_tag_values($tag) ) { #get all their values
	if( my ($db,$dbid) = $val =~ /(\S+):(\S+)/ ) {  #and render them as xrefs
	  $writer->startTag('dbxref');
	  $self->_element('xref_db', $db);
	  $dbid = $val if $db =~ /^[A-Z]O$/; # -> ontology, like GO
	  $self->_element('db_xref_id', $dbid);
	  $writer->endTag('dbxref');
	}
      }
    } else {
      push @passed_up,$tag;
    }
  }
  return @passed_up;
}


=head2 _render_target_tags

  Usage:
  Desc : process any 'Target' tags that would indicate a sequence alignment subject
  Ret  : array of tag names that we didn't render
  Args : feature object
  Side Effects: writes a <seq_relationship> of type 'subject' if it finds
                any properly formed tags named 'Target'
  Example:

  In game xml, <result_span>, <feature_span>, and <result_set> can have
  <seq_relationship>s.  <result_set> can only have one, a 'query' relation.

=cut

sub _render_target_tags {
  my ($self,$feat,@tagnames) = @_;
  my @passed_up;
  foreach my $tag (@tagnames) {
    if($tag eq 'Target' && (my @alignment = $feat->get_tag_values('Target')) >= 3) {
      $self->_seq_relationship('subject',
			       Bio::Location::Simple->new( -start => $alignment[1],
							   -end   => $alignment[2],
							 ),
			       $alignment[0],
			       $alignment[3],
			      );
    } else {
      push @passed_up, $tag;
    }
  }
  return @passed_up;
}


=head2 _property

 Title   : _property
 Usage   : $self->_property($tag => $value); 
 Function: an internal method to write property XML elements
 Returns : nothing
 Args    : a tag/value pair

=cut

sub _property {
    my ($self, $tag, $val) = @_;
    my $writer = $self->{writer};

    if ( length $val > 45 ) {
	my @val = split /\s+/, $val;
	$val = '';
	
	for my $word (@val) {
	    my ($lastline) = $val =~ /.*^(.+)$/sm;
	    $lastline ||= '';
	    $val .= length $lastline < 45 ? " $word " : "\n          $word";
	}
	$val = "\n         $val\n        ";
	$val =~ s/(\S)\s{2}(\S)/$1 $2/g;
    }
    $writer->startTag('property');
    $self->_element('type', $tag);
    $self->_element('value', $val);
    $writer->endTag('property');
}

=head2 _unflatten_attribute

 Title   : _unflatten_attribute
 Usage   : $self->_unflatten_attribute($name, $value)
 Function: an internal method to unflatten and write comment or evidence elements
 Returns : nothing
 Args    : a list of strings

=cut

sub _unflatten_attribute {
    my ($self, $name, $val) = @_;
    my $writer = $self->{writer};
    my %pair;
    my @pairs = split ';', $val;
    for my $p ( @pairs ) {
	my @pair = split '=', $p;
	$pair[0] =~ s/^\s+|\s+$//g;
	$pair[1] =~ s/^\s+|\s+$//g;
	$pair{$pair[0]} = $pair[1];
    }
    $writer->startTag($name);
    for ( keys %pair ) {
	$self->_element($_, $pair{$_});
    }
    $writer->endTag($name);
    

}

=head2 _xref

 Title   : _xref
 Usage   : $self->_xref($value) 
 Function: an internal method to write db_xref elements
 Returns : nothing 
 Args    : a list of strings

=cut

sub _xref {
    my ($self, @xrefs) = @_;
    my $writer = $self->{writer};
    for my $xref ( @xrefs ) {
	my ($db, $acc) = $xref =~ /(\S+):(\S+)/;
	$writer->startTag('dbxref');
	$self->_element('xref_db', $db);
	$acc = $xref if $db eq 'GO';
	$self->_element('db_xref_id', $acc);
	$writer->endTag('dbxref');
    }
}

=head2 _feature_span

 Title   : _feature_span
 Usage   : $self->_feature_span($name, $type, $loc)
 Function: an internal method to write a feature_span element
          (the actual feature with coordinates)
 Returns : nothing 
 Args    : a feature name and Bio::SeqFeatureI-compliant object

=cut

sub _feature_span {
    my ($self, $name, $feat, $pname) = @_;
    my $type = $feat->primary_tag;
    my $writer = $self->{writer};
    my %atts = ( id => $name );
    
    if ( $pname ) {
	$pname =~ s/-R/-P/;
	$atts{produces_seq} = $pname;
    }

    $writer->startTag('feature_span', %atts );
    $self->_element('name', $name);
    $self->_element('type', $type);
    $self->_seq_relationship('query', $feat);
    $writer->endTag('feature_span');
}

=head2 _seq_relationship

 Title   : _seq_relationship
 Usage   : $self->_seq_relationship($type, $loc)
 Function: an internal method to handle feature_span sequence relationships
 Returns : nothing
 Args    : feature type, a Bio::LocationI-compliant object,
           (optional) sequence name (defaults to the query seq)
           and (optional) alignment string

=cut

sub _seq_relationship {
    my ($self, $type, $loc, $seqname, $alignment) = @_;
    my $writer = $self->{'writer'};

    $seqname ||= #if no seqname passed in, use the name of our annotating seq
      $self->{seq}->accession_number ne 'unknown' && $self->{seq}->accession_number
	|| $self->{seq}->display_id || 'unknown';
    $writer->startTag(
		      'seq_relationship',
		      type => $type,
		      seq  => $seqname,
		     );
    $self->_span($loc);
    $writer->_element('alignment',$alignment) if $alignment;
    $writer->endTag('seq_relationship');
}

=head2 _element

 Title   : _element
 Usage   : $self->_element($name, $chars, $atts)
 Function: an internal method to generate 'generic' XML elements
 Example : 
 my $name = 'foo';
 my $content = 'bar';
 my $attributes = { baz => 1 }; 
 # print the element
 $self->_element($name, $content, $attributes);
 Returns : nothing 
 Args    : the element name and content plus a ref to an attribute hash

=cut

sub _element {
    my ($self, $name, $chars, $atts) = @_;
    my $writer = $self->{writer};
    my %atts = $atts ? %$atts : ();
    
    $writer->startTag($name, %atts);
    $writer->characters($chars);
    $writer->endTag($name);
}

=head2 _span

 Title   : _span
 Usage   : $self->_span($loc)
 Function: an internal method to write the 'span' element
 Returns : nothing
 Args    : a Bio::LocationI-compliant object

=cut

sub _span {
    my ($self, @loc) = @_;
    my ($loc, $start, $end);

    if ( @loc == 1 ) {
	$loc = $loc[0];
    }
    elsif ( @loc == 2 ) {
	($start, $end) = @loc;
    }

    if ( $loc ) {
	($start, $end) = ($loc->start, $loc->end);
	($start, $end) = ($end, $start) if $loc->strand < 0;
    } 
    elsif ( !$start ) {
	($start, $end) = (1, $self->{seq}->length);
    }
    
    my $writer = $self->{writer};
    $writer->startTag('span');
    $self->_element('start', $start);
    $self->_element('end', $end);
    $writer->endTag('span');
}

=head2 _seq

 Title   : _seq
 Usage   : $self->_seq($seq, $dna) 
 Function: an internal method to print the 'sequence' element
 Returns : nothing
 Args    : and Bio::SeqI-compliant object and a reference to an attribute  hash

=cut

sub _seq {
    my ($self, $seq, $atts) = @_;

    my $writer = $self->{'writer'};

   
    # game moltypes
    my $alphabet = $seq->alphabet;
    $alphabet ||= $seq->mol_type if $seq->can('mol_type');
    $alphabet =~ s/protein/aa/;
    $alphabet =~ s/rna/cdna/;
    
    my @seq = ( 'seq',
		id     => $atts->{name},
		length => $seq->length,
		type   => $alphabet,
	       	focus  => "true"	       
	      );

    if ( $atts->{md5checksum} ) {
	push @seq, (md5checksum => $atts->{md5checksum});
	delete $atts->{md5checksum};
    }
    $writer->startTag(@seq);

    for my $k ( keys %{$atts} ) {
	if ( $k =~ /xref/ ) {
	    $self->_xref($atts->{$k});
	}
	else {
	    $self->_element($k, $atts->{$k});
	}    
    }
    
    # add leading spaces and line breaks for 
    # nicer xml formatting/indentation
    my $sp  = (' ' x 6);
    my $dna = $seq->seq;
    $dna =~ s/(\w{60})/$1\n$sp/g;
    $dna = "\n$sp" . $dna . "\n    ";
    
    if ( $seq->species && !$self->{has_organism}) {
        my $species = $seq->species->binomial;
	$self->_element('organism', $species);
    }
    
    $self->_element('residues', $dna);
    $writer->endTag('seq');
}

=head2 _find_name

 Title   : _find_name
 Usage   : my $name = $self->_find_name($feature)
 Function: an internal method to look for a gene name
 Returns : a string 
 Args    : a Bio::SeqFeatureI-compliant object

=cut

sub _find_name {
    my ($self, $feat, $key) = @_;
    my $name;
    
    if ( $key && $feat->has_tag($key) ) {
	($name) = $feat->get_tag_values($key);
	return $name;
    }
    else {
#      warn "Could not find name '$key'\n";
	return '';
    }
}

1;
