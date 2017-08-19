# some of the following code was pillaged from the CPAN module
# XML::Handler::Subs
#
# Copyright (C) 1999 Ken MacLeod
# XML::Handler::XMLWriter is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

#
# BioPerl module for Bio::SeqIO::game::gameSubs
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Sheldon McKay <mckays@cshl.edu>
#
# You may distribute this module under the same terms as perl itself
#

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::game::gameSubs -- a base class for game-XML parsing

=head1 SYNOPSIS

Not used directly

=head1 DESCRIPTION

A bag of tricks for game-XML parsing.  The PerlSAX handler methods were
stolen from Chris Mungall's XML base class, which he stole from Ken MacLeod's
XML::Handler::Subs

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

package Bio::SeqIO::game::gameSubs;
use XML::Parser::PerlSAX;
use UNIVERSAL;
use strict;

use vars qw {};
use base qw(Bio::Root::Root);


=head2 new

 Title   : new
 Usage   : not used directly
 Returns : a gameHandler object
 Args    : an XML filename

=cut

sub new {
    my $type = shift;
    my $file = shift || "";
    my $self = (@_ == 1) ? { %{ (shift) } } : { @_ };
    if ($file) {
	$self->{file} = $file;
    }

    return bless $self, $type;
}


=head2 go

 Title   : go
 Usage   : not used directly
 Function: starts PerlSAX XML parsing

=cut

sub go {
    my $self = shift;
    XML::Parser::PerlSAX->new->parse(Source => { SystemId => "$self->{file}" },
				     Handler => $self);
}

=head2 start_document

 Title   : start_document
 Usage   : not used directly 

=cut

sub start_document {
    my ($self, $document) = @_;

    $self->{Names} = [];
    $self->{Nodes} = [];
}



=head2 end_document

 Title   : end_document
 Usage   : not used directly

=cut

sub end_document {
    my ($self, $document) = @_;

    delete $self->{Names};
    delete $self->{Nodes};

    return();
}

=head2 start_element

 Title   : start_element
 Usage   : not used directly

=cut

sub start_element {
    my ($self, $element) = @_;

    $element->{Children} = [];

    $element->{Name} =~ tr/A-Z/a-z/;
    push @{$self->{Names}}, $element->{Name};
    push @{$self->{Nodes}}, $element;

    my $el_name = "s_" . $element->{Name};
    $el_name =~ s/[^a-zA-Z0-9_]/_/g;
    if ($ENV{DEBUG_XML_SUBS}) {
	print STDERR "xml_subs:$el_name\n";
    }
    if ($self->can($el_name)) {
	$self->$el_name($element);
	return 1;
    }

    return 0;
}

=head2 end_element

 Title   : end_element
 Usage   : not used directly

=cut

sub end_element {
    my ($self, $element) = @_;

    my $called_sub = 0;
    
    $element->{Name} =~ tr/A-Z/a-z/;
    
    my $el_name = "e_" . $element->{Name};
    $el_name =~ s/[^a-zA-Z0-9_]/_/g;
    
    my $rval = 0;
    if ($ENV{DEBUG_XML_SUBS}) {
	print STDERR "xml_subs:$el_name\n";
    }
    if ($self->can($ {el_name})) {
	$rval = $self->$el_name($element) || 0;
	$called_sub = 1;
    }
    my $curr_element = $self->{Nodes}->[$#{$self->{Nodes}}];

    pop @{$self->{Names}};
    pop @{$self->{Nodes}};

    if ($rval eq -1 || !$called_sub) {
	if (@{$self->{Nodes}}) {
	    my $parent = $self->{Nodes}->[$#{$self->{Nodes}}];
	    push(@{$parent->{Children}}, $curr_element);
	    $parent->{"_".$curr_element->{Name}} = $curr_element;
	}
    }

    return $called_sub;
}



=head2 characters

 Title   : characters
 Usage   : not used directly

=cut

sub characters {
    my ($self, $characters) = @_;

    my $str = $self->strip_characters($characters->{Data});
    my $curr_element = $self->curr_element();
    $curr_element->{Characters} .= $str;
    0;
}

=head2 strip_characters

 Title   : strip_characters
 Usage   : not used directly
 Function: cleans up XML element contents

=cut

sub strip_characters {
    my ($self, $str) = @_;
    $str =~ s/^[ \n\t]* *//g;
    $str =~ s/ *[\n\t]*$//g;
    $str;
}

=head2 curr_element

 Title   : curr_element
 Usage   : not used directly
 Function: returns the currently open element

=cut

sub curr_element {
    my $self = shift;
    return $self->{Nodes}->[-1];
}

=head2 flush

 Title   : flush
 Usage   : $self->flush($element) # or $element->flush
 Function: prune a branch from the XML tree
 Returns : true if successful
 Args    : an element object (optional)

=cut

sub flush {
    my $self = shift;
    my $victim = shift || $self->curr_element;
    $victim = {};
    return 1;
}

# throw a non-fatal warning

=head2 complain

 Title   : complain
 Usage   : $self->complain("This is terrible; I am not happy")
 Function: throw a non-fatal warning, formats message for pretty-printing
 Returns : nothing
 Args    : a list of strings

=cut

sub complain {
    my $self = shift;
    return 0 unless $self->{verbose};
    my $msg  = join '', @_;
    $msg =~ s/\n/ /g;
    my @msg = split /\s+/, $msg;
    my $new_msg = '';
    
    for ( @msg ) {
        my ($last_chunk) = $new_msg =~ /\n?(.+)$/;
	my $l = $last_chunk ? length $last_chunk : 0; 
	if ( (length $_) + $l > 45 ) {
	    $new_msg .= "\n$_ ";
	}
	else {
	    $new_msg .= $_ . ' ';
	}
    }
    
    $self->warn($new_msg);
}

=head2 dbxref

 Title   : dbxref
 Usage   : $self->db_xref($el, $tags) 
 Function: an internal method to flatten dbxref elements
 Returns : the db_xref (eg wormbase:C02D5.1)
 Args    : an element object (reqd) and a hash ref of tag/values (optional)

=cut

sub dbxref {                                                                                 
    my ($self, $el, $tags) = @_;
    $tags ||= $self->{curr_tags};
    my $db  = $el->{_xref_db}->{Characters};
    my $acc = $el->{_unique_id}  ||
              $el->{_db_xref_id} ||                                                                      
              $el->{_xref_db_id};
    my $id  = $acc->{Characters} or return 0;                                                          
    $self->flush( $el );
    
    # capture both the database and accession number
    $id=  $id =~ /^\w+$/ ? "$db:$id" : $id;
    $tags->{dbxref} ||= [];
    push @{$tags->{dbxref}}, $id;
    $id;
}


=head2 comment

 Title   : comment
 Usage   : $self->comment($comment_element)
 Function: a method to flatten comment elements
 Returns : a string
 Args    : an comment element (reqd) and a hash ref of tag/values (optional)
 Note    : The hope here is that we can unflatten structured comments
           in game-derived annotations happen to make a return trip

=cut

sub comment {
    my ($self, $el, $tags) = @_;
        
    $tags ||= $self->{curr_tags};
    my $text = $el->{_text}->{Characters};
    my $pers = $el->{_person}->{Characters};
    my $date = $el->{_date}->{Characters};
    my $int  = $el->{_internal}->{Characters};
    $self->flush( $el );
    
    my $comment = "person=$pers; "  if $pers;
    $comment   .= "date=$date; "    if $date;
    $comment   .= "internal=$int; " if $int;
    $comment   .= "text=$text"      if $text;
    
    $tags->{comment} ||= [];
    push @{$tags->{comment}}, $comment;
    $comment;
}

=head2 property

 Title   : property
 Usage   : $self->property($property_element)
 Function: an internal method to flatten property elements
 Returns : a hash reference
 Args    : an property/output element (reqd) and a hash ref of tag/values (optional)
 Note: This method is aliased to 'output' to handle structurally identical output elements

=cut

*output = \&property;
sub property {
    my ($self, $el, $tags) = @_;
    
    $tags   ||= $self->{curr_tags};
    my $key   = $el->{_type}->{Characters};
    my $value = $el->{_value}->{Characters};
    $self->flush( $el );    
    
    $tags->{$key} ||= [];
    push @{$tags->{$key}}, $value;
    $tags;
}

=head2 evidence

 Title   : evidence
 Usage   : $self->evidence($evidence_element)
 Function: a method to flatten evidence elements
 Returns : a string
 Args    : an evidence element

=cut

sub evidence {                                                                                     
    my ($self, $el) = @_;                                                                           
    my $tags = $self->{curr_tags};                                                                  
    my $text = $el->{Characters} or return 0;                                                       
    my $type = $el->{Attributes}->{type};                                                           
    my $res  = $el->{Attributes}->{result};                                                         
    $self->flush( $el );
                                                                                                
    my $evidence = "type=$type; " if $type;                                                         
    $evidence   .= "result=$res; " if $res;                                                         
    $evidence   .= "evidence=$text";
    
    $tags->{evidence}||= [];
    push @{$tags->{evidence}}, $evidence;                                                                
    $evidence;                                                                                      
} 

=head2 date

 Title   : date
 Usage   : $self->date($date_element)
 Function: a method to flatten date elements
 Returns : true if successful
 Args    : a date element

=cut

sub date {
    my ($self, $el) = @_;
    my $tags  = $self->{curr_tags};
    my $date  = $el->{Characters} or return 0;
    my $stamp = $el->{Attributes}->{timestamp};
    $self->flush( $el );
    
    $tags->{date} ||= [];
    push @{$tags->{date}}, $date;
    $tags->{timestamp} ||= [];
    push @{$tags->{timestamp}}, $stamp;
    1;
}


=head2 protein_id

 Title   : protein_id
 Usage   : $pid = $self->protein_id($cds, $standard_name)
 Function: a method to search for a protein name
 Returns : a string
 Args    : the CDS object plus the transcript\'s 'standard_name'

=cut

sub protein_id {
    my ($self, $cds, $sn) = @_;
    my $psn;
    if ( $cds->has_tag('protein_id') ) {
        ($psn) = $cds->get_tag_values('protein_id');
    }
    elsif ( $cds->has_tag('product') ) {
        ($psn) = $cds->get_tag_values('product');
        $psn =~ s/.+?(\S+)$/$1/;
    }
    elsif ( $cds->has_tag('gene') ) {
        ($psn) = $cds->get_tag_values('gene');
    }
    elsif ( $sn ) {
	$psn = $sn;
    }
    else {
        $self->complain("Could not find an ID for the protein");
        return '';
    }

    $psn =~ s/-R/-P/;
    return $psn;
}

1;

