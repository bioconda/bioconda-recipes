#
# BioPerl module for Bio::SeqIO::game::seqHandler
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Sheldon McKay <mckays@cshl.edu>
#
# You may distribute this module under the same terms as perl itself
#

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::game::seqHandler -- a class for handling game-XML sequences

=head1 SYNOPSIS

This modules is not used directly

=head1 DESCRIPTION

Bio::SeqIO::game::seqHandler processes all of the sequences associated with a game record
and, via feature handlers, processes the associated annotations

=head1 FEEDBACK

=head2 Mailing Lists

User feedback is an integral part of the evolution of this
and other Bioperl modules. Send your comments and suggestions preferably
to one of the Bioperl mailing lists.

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

package Bio::SeqIO::game::seqHandler;

use Data::Dumper;

use Bio::SeqIO::game::featHandler;
use Bio::SeqFeature::Generic;
use Bio::Seq::RichSeq;
use Bio::Species;
use strict;

use vars qw {};

use base qw(Bio::SeqIO::game::gameSubs);

=head2 new

 Title   : new
 Usage   : my $seqHandler = Bio::SeqIO::game::seqHandler->new($seq, $ann, $comp, $map, $src )
 Function: constructor method to create a sequence handler
 Returns : a sequence handler object
 Args    : $seq  -- an XML sequence element
           $ann  -- a ref. to a list of <annotation> elements
           $comp -- a ref. to a list of <computational_analysis> elements (not used yet)
           $map  -- a <map_position> element
           $src  -- a flag to indicate that the sequence already has a source feature

=cut

sub new {
    my ($caller, $seq, $ann, $comp, $map, $src ) =  @_;

    my $class = ref($caller) || $caller;

    my $self = bless ( { 
	seqs     => $seq,
        anns     => $ann,
        comps    => $comp,
        map_pos  => $map,
	has_source => $src,
        seq_h    => {},
	ann_l    => []
    }, $class );

    return $self;
}

=head2 convert

 Title   : convert
 Usage   : @seqs = $seqHandler->convert
 Function: converts the main XML sequence element and associated annotations to Bio::
 Returns : a ref. to a an array containing the sequence object and a ref. to a list of  features
 Args    : none

 Note    : The features and sequence are kept apart to facilitate downstream filtering of features 

=cut

sub convert {
    my $self = shift;
    my @ann  = @{$self->{anns}} if defined $self->{anns};;
    my @seq  = @{$self->{seqs}};
    
    # not used yet
    my @comp;
    if ( $self->{comps} ) {
        @comp = @{$self->{comps}}    
    }
    
    # process the sequence elements
    for ( @seq ) {
	$self->_add_seq( $_ );
    }
    
    # process the annotation elements
    for ( @ann ) {
	$self->_annotation( $_ );
    }
    
    return $self->_order_feats( $self->{seq_h} );
}

=head2 _order_feats

 Title   : _order_feats
 Usage   : $self->_order_feats( $self->{seq_h} )
 Function: an internal method to ensure the source feature comes first
           and keep gene, mRNA and CDS features together 
 Returns : a ref. to an array containing the sequence object and a ref. to a list of  features 
 Args    : a ref. to a hash of sequences

=cut

sub _order_feats {
    my ($self, $seqs) = @_;
    my $seq = $self->{main_seq};
    my $id  = $seq->id;
    my $ann = $self->{ann_l};

    # make sure source(s) come first
    my @src   = grep { $_->primary_tag =~ /source|origin|\bregion\b/ } @$ann;
    # preserve gene->mRNA->CDS or ncRNA->gene->transcript order
    my @genes = grep { $_->primary_tag =~ /gene|CDS|[a-z]+RNA|transcript/ } @$ann;
    my @other = sort { $a->start <=> $b->start || $b->end   <=> $a->end  } 
                grep { $_->primary_tag !~ /source|origin|\bregion\b/ } 
                grep { $_->primary_tag !~ /gene|mRNA|CDS/ } @$ann;
    
    return [$seq, [@src, @genes, @other]];
}

=head2 _add_seq

 Title   : _add_seq
 Usage   : $self->_add_seq($seq_element)
 Function: an internal method to process the sequence elements
 Returns : nothing
 Args    : a sequence element

=cut

sub _add_seq {
    my ($self, $el) = @_;
    my $residues = '';

    if ($el->{_residues}) {
        $residues = $el->{_residues}->{Characters};
        $residues =~ s/[ \n\r]//g;
        $residues =~ s/\!//g;
        $residues =~ tr/a-z/A-Z/;
    } 
    else {
	return 0;
    }

    my $id   = $el->{Attributes}->{id};
    my $ver  = $el->{Attributes}->{version};
    my $name = $el->{_name}->{Characters};
    
    if ($name && $name ne $id) {
        $self->complain("The sequence name and unique ID do not match.  Using ID");
    }
    
    # get/set the sequence object
    my $seq = $self->_seq($id);
    
    # get/set the feature handler
    my $featHandler = $self->_feat_handler;
    
    # populate the sequence object
    $seq->seq($residues);
    $seq->seq_version($ver) if $ver;
    
    # assume the id is the accession number
    if ( $id =~ /^\w+$/ ) {
	$seq->accession($id);
    }
    
    # If the focus attribute is set to "true", this is the main
    # sequence
    my $focus = 0;
    if ( defined $el->{Attributes}->{focus} ) {
        $self->{main_seq} = $seq;
        $focus++;
    }

    # make sure real and annotated lengths match
    my $length = $el->{Attributes}->{'length'};
    $length && $seq->length(int($length));
    if ( $seq->seq && defined($length) && $seq->length != int($length) ) {
        $self->complain("The specified sequence has length ", $seq->length(),
                        " but the length attribute= ", $length);
        $seq->seq( undef );
        $seq->length( int($length) );
    }

    # deal with top-level annotations
    my $tags = {};
    if ( $el->{Attributes}->{md5checksum} ) {
	$tags->{md5checksum} = [$el->{Attributes}->{md5checksum}];
    }
    if ($el->{_dbxref}) {
	$tags->{dbxref} ||= [];
        push @{$tags->{dbxref}}, $self->dbxref( $el->{_dbxref} );
    }
    if ($el->{_description}) {
        my $desc = $el->{_description}->{Characters};
        $seq->description( $desc );
    } 
    if ($el->{_organism}) {
        my @organism = split /\s+/, $el->{_organism}->{Characters};
        if (@organism < 2) {
	    $self->complain("Species name should have at least two words");
	}
	else {
	    my $species = Bio::Species->new( -classification => [reverse @organism] );
	    $seq->species($species);
	}
    }
    if ( defined($seq->species) ) {
	$tags->{organism} = [$seq->species->binomial];
    }
#    elsif ($seq eq $self->{main_seq}) {
#	$self->warn("The source organism for this sequence was\n" .
#		    "not specified.  I will guess Drosophila melanogaster.\n" .
#		    "Otherwise, add <organism>Genus species</organism>\n" .
#		    "to the main sequence element");
#	my @class = qw/ Eukaryota Metazoa Arthropoda Insecta Pterygota
#	                Neoptera Endopterygota Diptera Brachycera 
#	                Muscomorpha Ephydroidea Drosophilidae Drosophila melanogaster/;
#	my $species = Bio::Species->new( -classification => [ reverse @class ],
#					 -common_name    => 'fruit fly' );
#	$seq->species( $species );
#    }
    
    # convert GAME to bioperl molecule types
    my $alphabet = $el->{Attributes}->{type};
    if ( $alphabet ) {
        $alphabet =~ s/aa/protein/;
	$alphabet =~ s/cdna/rna/;
	$seq->alphabet($alphabet);
    }

    # add a source feature if req'd
    if ( !$self->{has_source} && $focus ) {
	#$self->{source} = $featHandler->add_source($seq->length, $tags);
    }
    
    if ( $focus ) {
        # add the map position
        $self->_map_position( $self->{map_pos}, $seq );
        $featHandler->{offset} = $self->{offset};
    }
    
    # prune the sequence from the parse tree
    $self->flush;
}

=head2 _map_position

 Title   : _map_position
 Usage   : $self->_map_position($map_posn_element)
 Function: an internal method to process the <map_position> element
 Returns : nothing
 Args    : a map_position element

=cut

sub _map_position {
    my ($self, $el) = @_;

    # we can live without it
    if ( !$el ) {
	$self->{offset}= 0;
	return 0;
    }


    # chromosome and coordinates
    my $arm   = $el->{_arm}->{Characters};
    my $type  = $el->{Attributes}->{type};
    my $loc   = $el->{_span};
    my $start = $loc->{_start}->{Characters};
    my $end   = $loc->{_end}->{Characters};
    
    # define the offset (may be a partial sequence)
    # The coordinates will be relative but the CDS description
    # coordinates may be absolute if the game-XML comes from apollo 
    # or gadfly
    $self->{offset} = $start - 1;

    my $seq_id = $el->{Attributes}->{seq};
    my $seq = $self->{seq_h}->{$seq_id};
    
    unless ( $seq ) {
        $self->throw("Map position with no corresponding sequence object");
    }
    unless ($seq eq $self->{main_seq}){
        $self->throw("Map position does not correspond to the main sequence");
    }
    
    my $species = '';
    
    # create/update the top-level sequence feature if req'd
    if ( $self->{source} ) {
	my $feat = $self->{source};
    
	unless ($feat->has_tag('organism')) {
	    $species = eval {$seq->species->binomial} || 'unknown species';
	    $feat->add_tag_value( organism => $species );
	}
    
	my %tags = ( mol_type   => "genomic dna",
		     chromosome => $arm,
		     location   => "$start..$end",
		     type       => $type
		     );
    
	for (keys %tags) {
	    $feat->add_tag_value( $_ => $tags{$_} );
	}
        
	$seq->add_SeqFeature($feat);
    }

    # come up with a description if there is none
    my $desc = $seq->description;
    if ( $species && $arm && $start && $end && !$desc) {
	$seq->description("$species chromosome $arm $start..$end " .
	                  "segment of complete sequence");
    }
    
    $self->flush;
}

=head2 _annotation

 Title   : _annotation
 Usage   : $self->_annotation($annotation_element)
 Function: an internal method to process <annotation> elements
 Returns : nothing
 Args    : an annotation element

=cut

sub _annotation {
    my ($self, $el) = @_;

    my $id      = $el->{Attributes}->{id};
    my $type    = $el->{_type}->{Characters};
    my $tags    = {};
    my $gname   = $el->{_name}->{Characters} eq $id ? '' : $el->{_name}->{Characters};

    # 'transposable element' is too long (breaks Bio::SeqIO::GenBank)
    # $type =~ s/transposable_element/repeat_region/;
    
    # annotations must be on the main sequence
    my $seqid = $self->{main_seq}->id;
    my $featHandler = $self->_feat_handler;
    
    my @feats = ();
    
    for my $child ( @{$el->{Children}} ) {
        my $name = $child->{Name};
	
	# these elements require special handling
	if ( $name eq 'dbxref' ) {
	    $tags->{dbxref} ||= [];
	    push @{$tags->{dbxref}}, $self->dbxref( $child );
	}
	elsif ( $name eq 'aspect' ) {
	    $tags->{dbxref} ||= [];
	    push @{$tags->{dbxref}}, $self->dbxref( $child->{_dbxref} );
	}
        elsif ( $name eq 'feature_set' ) {
            push @feats, $featHandler->feature_set( $id, $gname, $child, $type );
	}
        elsif ( $name eq 'comment' ) {
	    $tags->{comment} = [$self->comment( $child )];
	}
	elsif ( $name eq 'property' ) {
	    $self->property( $child, $tags );
	}
	elsif ( $name eq 'gene' ) {
	    # we may be dealing with an annotation that is not
	    # a gene, so we have to nest the gene inside it
	    $featHandler->has_gene( $child, $gname, $id )
        }
        
	# otherwise, tag/value pairs
	# -- mild dtd enforcement
	# synonym is not in the dtd but shows up in gadfly
	# annotations	
	elsif ( $name =~ /type|synonym/ ) {
	    $tags->{$name} = [$child->{Characters}];
	}
	elsif ( $name ne 'name' ) {
            $self->complain("Unrecognized element '$name'. I don't " .
                            "know what to do with $name elements in " .
                            "top-level sequence annotations." );
        }

    }
	
    # add a gene annotation if required
    unless ( $featHandler->has_gene || $type ne 'gene' ) {
	$featHandler->has_gene( $el, $gname, $id )
    }

    if ( $tags->{symbol} ) {
        if ( !$tags->{gene} ) {
	   $tags->{gene} = $tags->{symbol};
	}
	delete $tags->{symbol};
    }
    
    
    $featHandler->add_annotation( $self->{main_seq}, $type, $id, $tags, \@feats );
    $self->flush;
}

# get/set the sequence object

=head2 _seq

 Title   : _seq
 Usage   : my $seq = $self->_seq
 Function: an internal sequence getter/setter
 Returns : a Bio::RichSeq object
 Args    : a sequence ID

=cut

sub _seq {
    my ($self, $id) = @_;
    $id || $self->throw("A unique id must be provided for the sequence");
    
    my $seq = {};
    
    if ( defined $self->{seq_h}->{$id}) {
	$seq = $self->{seq_h}->{$id};
    } else {
	$seq = Bio::Seq::RichSeq->new( -id => $id );
        $self->{seq_h}->{$id} = $seq; # store it
    }
    
    return $seq;
}

#get/set the feature handler

=head2 _feat_handler

 Title   : _feat_handler
 Usage   : my $featHandler = $self->_featHandler
 Function: an internal getter/setter for feature handling objects 
 Returns : a Bio::SeqIO::game::featHandler object
 Args    : none

=cut

sub _feat_handler {
    my $self = shift;
    
    my $handler = {};
    my $seq = $self->{main_seq};
    
    if ( defined $self->{feat_handler} ) {
	$handler = $self->{feat_handler};
    }
    else {
        my @args = ( $seq, $self->{seq_h}, $self->{ann_l} );
	$handler = Bio::SeqIO::game::featHandler->new( @args );
        $self->{feat_handler} = $handler;
    }

    return $handler;
}

1;


