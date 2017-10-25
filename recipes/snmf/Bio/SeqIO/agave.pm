# BioPerl module: Bio::SeqIO::agave
#
# AGAVE: Architecture for Genomic Annotation, Visualization and Exchange.
#
# You may distribute this module under the same terms as perl itself
#
# POD documentation - main docs before the code
#
# The original version of the module can be found here:
# http://www.agavexml.org/
#
# ### TODO: live link for this anymore?
# The DTD for AGAVE XML was once located here (dead link):
# http://www.lifecde.com/products/agave/schema/v2_3/agave.dtd
#
#
=head1 NAME

Bio::SeqIO::agave - AGAVE sequence output stream.

=head1 SYNOPSIS

It is probably best not to use this object directly, but
rather go through the SeqIO handler system. Go:

  $in  = Bio::SeqIO->new('-file'   => "$file_in",
                         '-format' => 'EMBL');

  $out = Bio::SeqIO->new('-file'   => ">$file_out",
                         '-format' => 'AGAVE');

  while (my $seq = $in->next_seq){
        $out->write_seq($seq);
  }

=head1 DESCRIPTION

This object can transform Bio::Seq objects to agave xml file and
vice-versa.  I (Simon) coded up this module because I needed a parser
to extract data from AGAVE xml to be utitlized by the GenQuire genome
annotation system (See http://www.bioinformatics.org/Genquire).

***NOTE*** At the moment, not all of the tags are implemented.  In
general, I followed the output format for the XEMBL project
http://www.ebi.ac.uk/xembl/

=cut

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

=head1 AUTHOR - Simon K. Chan

Email:

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# ===================


# Let the code begin...
package Bio::SeqIO::agave;
use strict;

use IO::File;


use Bio::SeqFeature::Generic;
use Bio::Seq;
use Bio::PrimarySeq;
use Bio::Seq::SeqFactory;
use Bio::Annotation::Reference;
use Bio::Species;

use XML::Writer;

use Data::Dumper;

use base qw(Bio::SeqIO);

# ==================================================================================
sub _initialize {

    my ($self,@args) = @_;
    $self->SUPER::_initialize(@args); # Run the constructor of the parent class.

    my %tmp = @args ;
    $self->{'file'} = $tmp{'-file'};

    if ($self->{'file'} !~ /^>/) {
        $self->_process;
        # Parse the thing, but only if it is the input file (ie not
        # outputing agave file, but reading it).
        $self->{'parsed'} = 1;
        # Set the flag to let the code know that the agave xml file
        # has been parsed.
    }
    $self->{'seqs_stored'} = 0;

}
# ==================================================================================

=head2 _process

  Title    : _process
  Usage    : $self->_process
  Function : Parses the agave xml file.
  Args     : None.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : _initialize
             Method(s) that this method calls   : _process_sciobj
             FIRST/START sub.

=cut

sub _process {
    my ($self) = @_;

    while (1) {

        my $line = $self->_readline;
        next unless $line;
        next if $line =~ /^\s*$/;

        if ($line =~ /<\?xml version/o) {

            # do nothing

        } elsif ($line =~ /\<!DOCTYPE (\w+) SYSTEM "([\w\.]+)"\>/) {

            $self->throw("Error: This xml file is not in AGAVE format! DOCTYPE: $1 , SYSTEM: $2\n\n")
                if $1 ne 'sciobj' || $2 ne 'sciobj.dtd';

        } elsif ($line =~ /<sciobj (.*)>/) {

            push @{$self->{'sciobj'}}, $self->_process_sciobj($1);

        } elsif ($line =~ /<\/sciobj>/) {

            last;               # It is finished.

        } else {

            # throw an error message.  The above conditions should
            # take care all of the possible options...?
            # $self->throw("Error: Do not recognize this AGAVE xml
            # line: $line\n\n");

        }


    }                           # close while loop


    return;

}
# ==================================================================================

=head2 _process_sciobj

  Title    : _process_sciobj
  Usage    : $self->_process_sciobj
  Function : Parses the data between the <sciobj></sciobj> tags.
  Args     : The string that holds the attributes for <sciobj>.
  Returns  : Data structure holding the values parsed between
             the <sciobj></sciobj> tags.
  Note     : Method(s) that call(s) this method : _process
             Method(s) that this method calls   :
             _helper_store_attribute_list , _process_contig

=cut

sub _process_sciobj {

    my ($self, $attribute_line) = @_;
    my $sciobj;
    $self->_helper_store_attribute_list($attribute_line, \$sciobj);

    my $line = $self->_readline;

    # Zero or more <contig>
    while ($line =~ /<contig\s?(.*?)\s?>/) {
        my $contig = $self->_process_contig(\$line, $1);
        push @{$sciobj->{'contig'}}, $contig;
        # print "line in _process_sciobj: $line\n";
        # $line changes value within the subs called in this sub (_process_contig).
    }

    return $sciobj;
}
# ==================================================================================

=head2 _process_contig

  Title    : _process_contig
  Usage    : $self->_process_contig
  Function : Parses the data between the <contig></contig> tags.
  Args     : 2 scalars:
             - reference to a scalar holding the line to be parsed.
             - scalar holding the attributes for the <contig> tag
               to be parsed.
  Returns  : Data structure holding the values parsed between
             the <contig></contig> tags.
  Note     : Method(s) that call(s) this method : _process_sciobj
             Method(s) that this method calls   :
             _helper_store_attribute_list, _one_tag , _process_fragment_order

=cut

sub _process_contig {

    my ($self, $line, $attribute_line) = @_;

    my $contig;
    $self->_helper_store_attribute_list($attribute_line, \$contig);
    $$line = $self->_readline;

    # One <db_id>:
    $self->_one_tag($line, \$contig, 'db_id');


    # Zero or more <fragment_order>
    $self->_process_fragment_order($line, \$contig);

    return $contig;

}
# ==================================================================================

=head2 _process_fragment_order

  Title    : _process_fragment_order
  Usage    : $self->_process_fragment_order
  Function : Parses the data between the <fragment_order></fragment_order> tags.
  Args     : 2 scalars:
             - reference to a scalar holding the value of the line to be parsed.
             - reference to a data structure to store the <fragment_order> data.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : _process_contig
             Method(s) that this method calls   :
             _helper_store_attribute_list , _process_fragment_orientation

=cut

sub _process_fragment_order {


    my ($self, $line, $data_structure) = @_;
    # Because I'm passing a reference to a data structure, I don't need to return it
    # after values have been added.

    while ($$line =~ /<fragment_order\s?(.*?)\s?>/) {

        my $fragment_order;
        $self->_helper_store_attribute_list($1, \$fragment_order);
        # Store the attribute(s) for <fragment_order> into the
        # $fragment_order data structure.
        $$line = $self->_readline;

        # One or more <fragment_orientation>
        $self->_process_fragment_orientation($line, \$fragment_order);
        # Don't forget: $line is a reference to a scalar.

        push @{$$data_structure->{'fragment_order'}}, $fragment_order;
        # Store the data between <fragment_order></fragment_order>
        # in $$data_structure.

    }

    return;

}
# ==================================================================================

=head2 _process_fragment_orientation

  Title    : _process_fragment_orientation
  Usage    : $self->_process_fragment_orientation
  Function : Parses the data between the <fragment_orientation> and
             </fragment_orientation> tags.
  Args     : 2 scalars:
             - reference to a scalar holding the value of the line to be parsed.
             - reference to a data structure to store the <fragment_orientation> data.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : _process_fragment_order

Method(s) that this method calls : _helper_store_attribute_list ,
_process_bio_sequence

=cut

sub _process_fragment_orientation {


    my ($self, $line, $data_structure) = @_;

    # counter to determine the number of iterations within this while loop.
    my $count = 0;

    # One or more <fragment_orientation>
    while ($$line =~ /<fragment_orientation\s?(.*?)\s?>/) {

        my $fragment_orientation;
        $self->_helper_store_attribute_list($1, \$fragment_orientation);
        $$line = $self->_readline;

        # One <bio_sequence>
        $$line =~ /<bio_sequence\s?(.*?)\s?>/;
        # Process the data between <bio_sequence></bio_sequence>
        my $bio_sequence = $self->_process_bio_sequence($line, $1);
        $fragment_orientation->{'bio_sequence'} = $bio_sequence;

        push @{$$data_structure->{'fragment_orientation'}}, $fragment_orientation;

        ++$count;
    }


    $self->throw("Error: Missing <fragment_orientation> tag.  Got this: $$line\n\n")
        if $count == 0;

    return;

}
# ==================================================================================

=head2 _process_bio_sequence

  Title    : _process_bio_sequence
  Usage    : $self->_process_bio_sequence
  Function : Parses the data between the <bio_sequence></bio_sequence> tags.
  Args     : 2 scalars:
             - reference to a scalar holding the value of the line to be parsed.
             - scalar holding the value of the attributes for <bio_sequence>
  Returns  : data structure holding the values between <bio_sequence></bio_sequence>
  Note     : Method(s) that call(s) this method : _process_fragment_orientation

Method(s) that this method calls : _helper_store_attribute_list ,
_one_tag , _question_mark_tag , _star_tag , _process_alt_ids ,
_process_xrefs , _process_sequence_map

=cut

sub _process_bio_sequence {

    my ($self, $line, $attribute_line) = @_;

    my $bio_sequence;

    $self->_helper_store_attribute_list($attribute_line, \$bio_sequence);
    $$line = $self->_readline;


    # One <db_id>.
    $self->_one_tag($line, \$bio_sequence, 'db_id');


    # Zero or one <note>.
    $self->_question_mark_tag($line, \$bio_sequence, 'note');


    # Zero or more <description>
    $self->_question_mark_tag($line, \$bio_sequence, 'description');


    # Zero or more <keyword>
    $self->_star_tag($line, \$bio_sequence, 'keyword');


    # Zero or one <sequence>
    $self->_question_mark_tag($line, \$bio_sequence, 'sequence');


    # Zero or one <alt_ids>
    # NOT IMPLEMENTED!!!!
    #if ($line =~ /<alt_ids>/){ # NOT DONE YET!
    #       my $alt_ids;
    #       $bio_sequence->{'alt_ids'} = $self->_process_alt_ids(\$alt_ids);
    #}


    # Zero or one <xrefs>
    if ($$line =~ /<xrefs\s?(.*?)\s?>/) {
        my $xrefs = $self->_process_xrefs($line, \$bio_sequence);
        $bio_sequence->{'xrefs'} = $xrefs || 'null';
    }


    # Zero or more <sequence_map>
    if ($$line =~ /<sequence_map\s?(.*?)\s?>/) {
        my $sequence_map = $self->_process_sequence_map($line);
        push @{$bio_sequence->{'sequence_map'}}, $sequence_map;
    }

    # print Data::Dumper->Dump([$bio_sequence]); exit;

    return $bio_sequence;

}
# ==================================================================================

=head2 _process_xrefs

  Title    : _process_xrefs
  Usage    : $self->_process_xrefs
  Function : Parse the data between the <xrefs></xrefs> tags.
  Args     : reference to a scalar holding the value of the line to be parsed.
  Return   : Nothing.
  Note     : Method(s) that call(s) this method: _process_bio_sequence
             Method(s) that this method calls: _one_tag , _process_xref

=cut

sub _process_xrefs {

    my ($self, $line) = @_;

    my $xrefs;

    $$line = $self->_readline;

    # One or more <db_id> or <xref> within <xrefs></xrefs>.  Check if
    # to see if there's at least one.
    if ($$line =~ /<db_id|xref\s?(.*?)\s?>/) {

        while ($$line =~ /<(db_id|xref)\s?(.*?)\s?>/) {

            if ($1 eq "db_id") {

                my $db_id;
                $self->_one_tag($line, \$db_id, 'db_id');
                push @{$xrefs->{'db_id'}}, $db_id;

            } elsif ($1 eq "xref") {

                my $xref;
                $self->_process_xref($line, \$xref);
                push @{$xrefs->{'xref'}}, $xref;

            } else {

                $self->throw("Error:  Tag type should be one of db_id or xref!  Got this: $$line\n\n");
            }


        }                       # close while loop


        if ($$line =~ /<\/xrefs>/) {
            $$line = $self->_readline; # get the next line to be _processed by the next sub.
            return $xrefs;
        } else {
            $self->throw("Error: Missing </xrefs> tag.  Got this: $$line\n\n");
        }



    } else {

        $self->throw("Error: Missing <db_id> or <xref> tag.  Got this: $$line\n\n");
    }

    return;

}
# ==================================================================================

=head2 _process_xref

  Title    : _process_xref
  Usage    : $self->_process_xref
  Function : Parses the data between the <xref></xref> tags.
  Args     : 2 scalars:
             - reference to a scalar holding the value of the line to be parsed.
             - reference to a data structure to store the <xref> data.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : _process_xrefs (note the 's' in 'xrefs')
             Method(s) that this method calls   : _helper_store_attribute_list , _star_tag

=cut

sub _process_xref {

    my ($self, $line, $xref) = @_;

    $$line = $self->_readline;

    # One <db_id>
    if ($$line =~ /<db_id\s?(.*?)\s?>/) {
        $self->_helper_store_attribute_list($1, $xref);
    } else {
        $self->throw("Error:  Missing <db_id> tag.  Got this: $$line\n\n");
    }


    # Zero or more <xref_property>
    $self->_star_tag($line, $xref, 'xref_propery');

    return;

}
# ==================================================================================

=head2 _process_sequence_map

  Title    : _process_sequence_map
  Usage    : $self->_process_sequence_map
  Function : Parses the data between the <sequence_map></sequence_map> tags.
  Args     : Reference to scalar holding the line to be parsed.
  Returns  : Data structure that holds the values that were parsed.
  Note     : Method(s) that call(s) this method : _process_bio_sequence
             Method(s) that this method calls   : _helper_store_attribute_list ,
                _question_mark_tag , _process_annotations

=cut

sub _process_sequence_map {

    my ($self, $line) = @_;

    my $sequence_map;

    # Zero or more <sequence_map>
    while ($$line =~ /<sequence_map\s?(.*?)\s?>/) {

        $self->_helper_store_attribute_list($1, \$sequence_map) if defined $1;
        $$line = $self->_readline;

        # Zero or one <note>
        $self->_question_mark_tag($line, \$sequence_map, 'note');

        # NOT IMPLEMENTED!!!
        #if ($$line =~ /<computations\?(.*?)\s?>/){
        #       # $self->_process_computations();
        #}


        # Zero or one <annotations>
        if ($$line =~ /<annotations\s?(.*?)\s?>/) {
            my $annotations = $self->_process_annotations($line);
            $sequence_map->{'annotations'} = $annotations;
        }


    }                           # closes the while loop


    # Match closing tag:
    if ($$line =~ /<\/sequence_map>/) {
        return $sequence_map;
    } else {
        $self->throw("Error:  Missing </sequence_map> tag.  Got this: $$line\n\n");
    }


}
# ==================================================================================

=head2 _process_annotations

  Title    : _process_annotations
  Usage    : $self->_process_annotations
  Function : Parse the data between the <annotations></annotations> tags.
  Args     : Reference to scalar holding the line to be parsed.
  Returns  : Data structure that holds the values that were parsed.
  Note     : Method(s) that call(s) this method : _process_sequence_map
             Method(s) that this method calls   : _process_seq_feature

=cut

sub _process_annotations {

    my ($self, $line) = @_;
    # ( seq_feature | gene | comp_result )+

    my $annotations;

    $$line = $self->_readline;

    my $count = 0;              # counter to keep track of number of iterations in the loop.

    # One or more of these:
    while ($$line =~ /<(seq_feature|gene|comp_result)\s?(.*?)\s?>/) {

        if ($$line =~ /<seq_feature\s?(.*?)\s?>/) {

            my $seq_feature = $self->_process_seq_feature($line, $1);
            push @{$annotations->{'seq_feature'}}, $seq_feature;

        } elsif ($$line =~ /<gene\s?(.*?)\s?>/) {

            # gene

        } elsif ($$line =~ /<comp_result\s?(.*?)\s?>/) {

            # comp_result

        }

        ++$count;

    }                           # closes the while loop.

    $self->throw("Error:  Missing <seq_feature> tag.  Got: $$line\n\n") if $count == 0;

    # Match closing tag:
    if ($$line =~ /<\/annotations/) {

        $$line = $self->_readline; # get the next line to be _processed by the next sub.
        return $annotations;

    } else {
        $self->throw("Error:  Missing </annotations> tag.  Got this: $$line\n\n");
    }


}
# ==================================================================================

=head2 _process_seq_feature

  Title    : _process_seq_feature
  Usage    : $self->_process_seq_feature
  Function : Parses the data between the <seq_feature></seq_feature> tag.
  Args     : 2 scalars:
             - Reference to scalar holding the line to be parsed.
             - Scalar holding the attributes for <seq_feature>.
  Returns  : Data structure holding the values parsed.
  Note     : Method(s) that call(s) this method: _process_annotations

Method(s) that this method calls: _helper_store_attribute_list ,
_process_classification , _question_mark_tag , _one_tag ,
_process_evidence , _process_qualifier , _process_seq_feature ,
_process_related_annot

=cut

sub _process_seq_feature {

    my ($self, $line, $attribute_line) = @_;

    my $seq_feature;
    $self->_helper_store_attribute_list($attribute_line, \$seq_feature);


    $$line = $self->_readline;


    # Zero or more <classification>
    $self->_process_classification($line, \$seq_feature);



    # Zero or one <note>
    $self->_question_mark_tag($line, \$seq_feature, 'note');



    # One <seq_location>
    $self->_one_tag($line, \$seq_feature, 'seq_location');



    # Zero or one <xrefs>
    $self->_question_mark_tag($line, \$seq_feature, 'xrefs');



    # Zero or one <evidence>
    $self->_process_evidence($line, \$seq_feature);



    # Zero or more <qualifier>
    $self->_process_qualifier($line, \$seq_feature);



    # Zero or more <seq_feature>.  A <seq_feature> tag within a <seq_feature> tag?  Oh, well.  Whatever...
    while ($$line =~ /<seq_feature\s?(.*?)\s?>/) {
        $self->_process_seq_feature($line, $1);
        $$line = $self->_readline;
    }


    # Zero or more <related_annot>
    while ($$line =~ /<related_annot\s?(.*?)\s?>/) {
        $self->_process_related_annot($line, $1);
        $$line = $self->_readline;
    }


    # Match the closing tag:
    if ($$line =~ /<\/seq_feature>/) {

        $$line = $self->_readline; # for the next sub...
        return $seq_feature;

    } else {

        $self->throw("Error.  Missing </seq_feature> tag.  Got this: $$line\n");

    }

}
# ==================================================================================

=head2 _process_qualifier

  Title    : _process_qualifier
  Usage    : $self->_process_qualifier
  Function : Parse the data between the <qualifier></qualifier> tags.
  Args     : 2 scalars:
             - reference to a scalar holding the value of the line to be parsed.
             - reference to a data structure to store the <qualifer> data.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : _process_seq_feature
             Method(s) that this method calls   : _star_tag

=cut

sub _process_qualifier {

    my ($self, $line, $data_structure) = @_;

    my $qualifier;
    $self->_star_tag($line, \$qualifier, 'qualifier');
    push @{$$data_structure->{'qualifier'}},$qualifier;


    return;
    # No need to return the data structure since its reference was what was modified.

}
# ==================================================================================

=head2 _process_classification

  Title   : _process_classification
  Usage   : $self->_process_classification
  Function: Parse the data between the <classification></classification> tags.
  Args    :   2 scalars:
            - reference to a scalar holding the value of the line to be parsed.
            - reference to a data structure to store the <qualifer> data.
  Returns : Nothing.
  Note    : Method(s) that call(s) this method: _process_seq_feature

  Method(s) that this method calls: _helper_store_attribute_list ,
  _question_mark_tag , _star_tag, _process_evidence

=cut

sub _process_classification { # NOT IN USE.

    my ($self, $line, $data_structure) = @_;

    my $classification = $$data_structure->{'classification'};

    while ($$line =~ /<classification\s?(.*?)\s?>/) {

        $self->_helper_store_attribute_list($1, \$classification);

        # Zero or one <description>
        $self->_question_mark_tag($line, \$classification, 'description');

        # Zero or more <id_alias>
        $self->_star_tag($line, \$classification, 'id_alias');

        # Zero or one <evidence>
        $self->_process_evidence($line, \$classification);
    }


}
# ==================================================================================

sub _process_evidence { # NOT done.

    my ($self, $line, $data_structure) = @_;

    if ($$line =~ /<evidence>/) {

        $$line = $self->_readline;

        # One or more <element_id> OR One or more <comp_result>
        while ($$line =~ /<(element_id|comp_result)\s?(.*?)\s?>/) {
            if ($$line =~ /<element_id\s?(.*?)\s?>/) {
                my $element_id;
                $self->_plus_tag($line, \$element_id, 'element_id');
                push @{$$data_structure->{'element_id'}}, $element_id;
            } elsif ($$line =~ /<comp_result\s?(.*?)\s?>/) {
                my $comp_result;
                $self->_process_comp_result($line, \$comp_result, $1);
                push @{$$data_structure->{'comp_result'}}, $comp_result;
            }
            $$line = $self->_readline;
        }

    }


}
# ==================================================================================

sub _process_comp_result { # NOT IN USE.


    my ($self, $line, $comp_result, $attribute_line) = @_;

    $self->_helper_store_attribute_list($attribute_line, $comp_result);
    $$line = $self->_readline;

    # Zero or one <note>
    $self->_question_mark_tag($line, $comp_result, 'note');

    # Zero or one <match_desc>
    $self->_question_mark_tag($line, $comp_result, 'match_desc');

    # Zero or one <match_align>
    $self->_question_mark_tag($line, $comp_result, 'match_align');

    # Zero or one <query_region>
    $self->_process_query_region($line, $comp_result);

    # Zero or one <match_region>
    $self->_process_match_region($line, $comp_result);

    # Zero or more <result_property>
    $self->_star_tag($line, $comp_result, 'result_property');

    # Zero or more <result_group>
    $self->_process_result_group($line, $comp_result);

    # Zero or more <related_annot>
    $self->_process_related_annot($line, $comp_result);

}
# ==================================================================================

sub _process_related_annot { # NOT IN USE.

    my ($self, $line, $data_structure) = @_;

    while ($$line =~ /<related_annot\s?(.*?)\s?>/) {

        my $related_annot;
        # Zero or one <related_annot>
        $self->_helper_store_attribute_list($1, \$related_annot);
        $$line = $self->_readline;

        # One or more <element_id>
        my $element_id_count = 0;
        while ($$line =~ /<element_id\s?(.*?)\s?>/) {
            my $element_id;
            $self->_helper_store_attribute_list($1, \$element_id);
            push @{$related_annot->{'element_id'}}, $element_id;
            $$line = $self->_readline;
            ++$element_id_count;
        }

        if ($element_id_count == 0) {
            $self->throw("Error.  Missing <element_id> tag.  Got: $$line");
        }

        # Zero or more <sci_property>
        $self->_star_tag($line, \$related_annot, 'sci_property');
        # while ($$line =~ /<sci_property\s?(.*?)\s?>/){
        #
        # }

        push @{$data_structure->{'related_annot'}}, $related_annot;

        unless ($$line =~ /<\/related_annot>/){
            $self->throw("Error.  Missing </related_tag>. Got: $$line\n");
        }

    }


}
# ==================================================================================

sub _process_result_group { # NOT IN USE.

    my ($self, $line, $data_structure) = @_;

    while ($$line =~ /<result_group\s?(.*?)\s?>/) {
        my $result_group = $$data_structure->{'result_group'};
        $self->_helper_store_attribute_list($1, \$result_group);

        my $count = 0;
        $$line = $self->_readline;
        while ($$line =~ /<comp_result\s?(.*?)\s?>/) {
            # one or more <comp_result>
            $self->_process_comp_result(\$line, \$result_group, $1);
            $$line = $self->_readline;
            ++$count;
        }

        $self->throw("Error.  No <comp_result></comp_result> tag! Got this: $$line")
            if $count == 0;

        # in the last iteration in the inner while loop, $line will
        # have a value of the closing tag of 'result_group'
        if ($line =~ /<\/result_group>/) {
            $$line = $self->_readline;
        } else {
            $self->throw("Error.  No </result_tag>!  Got this: $$line");
        }


    }


}
# ==================================================================================

sub _process_match_region { # NOT IN USE.

    my ($self, $line, $data_structure) = @_;

    my $match_region = $data_structure->{'match_region'};

    if ($$line =~ /<match_region\s?(.*?)\s?>(.*?)>/) {

        $self->_helper_store_attribute_line($1, \$match_region);
        $$line = $self->_readline;

        # Zero or one db_id | element_id | bio_sequence
        if ($$line =~ /<db_id\s?(.*?)\s?>(.*?)<\/db_id>/) {
            $self->_question_mark_tag($line, \$match_region, 'db_id');
        } elsif ($$line =~ /<element_id\s?(.*?)\s?>/) { # empty...
            $self->_question_mark_tag($line, \$match_region, 'element_id');
        } elsif ($$line =~ /<bio_sequence\s?(.*?)\s?>/) {
            $match_region->{'bio_sequence'} = $self->_process_bio_sequence($line, $1);
        }

        $$line = $self->_readline;
        if ($$line =~ /<\/match_region>/o) {
            $$line = $self->_readline; # get the next line to be _processed by the next sub
            return;
        } else {
            $self->throw("No closing tag </match_region>!  Got this: $$line\n");
        }

    }
}
# ==================================================================================

sub _process_query_region { # NOT IN USE.

    my ($self, $line, $data_structure) = @_;

    my $query_region = $data_structure->{'query_region'};
    if ($$line =~ /<query_region\s?(.*?)\s?>/) {
        $self->_helper_store_attribute_list($1, \$query_region);
        $$line = $self->_readline;

        # Zero or one <db_id>
        $self->_question_mark_tag($line, \$query_region, 'db_id');

        if ($$line =~ /<\/query_region>/) {
            $$line = $self->_readline; # get the next line to _process.
            return;
        } else {
            $self->throw("No closing tag </query_region>.  Got this: $$line\n");
        }

    }


}
# ==================================================================================

=head2 _tag_processing_helper

  Title    : _tag_processing_helper
  Usage    : $self->_tag_processing_helper
  Function : Stores the tag value within the data structure.
             Also calls _helper_store_attribute_list to store the 
             attributes and their values in the data structure.
  Args     : 5 scalars:
             - Scalar holding the value of the attributes
             - Reference to a data structure to store the data for <$tag_name>
             - Scalar holding the tag name.
             - Scalar holding the value of the tag.
             - Scalar holding the value of either 'star', 'plus', 
               or 'question mark' which specifies what type of method
               called this method.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method:
             Method(s) that this method calls: _helper_store_attribute_list

=cut

sub _tag_processing_helper {

    my ($self, $attribute_list, $data_structure, $tag_name, $tag_value, $caller) = @_;

    # Add the attributes to the $$data_structure if they exist.
    # print "tag_name: $tag_name , attribute_list: $attribute_list\n";
    if (defined $attribute_list) {
        $self->_helper_store_attribute_list($attribute_list, $data_structure);
    }


    if ($caller eq 'star' || $caller eq 'plus') {
        push @{$$data_structure->{$tag_name}}, $tag_value;
        # There's either zero or more tags (*) or one or more (+)
    } else {
        $$data_structure->{$tag_name} = $tag_value || 'null';
        # There's zero or one tag (?)
    }

    return;

}
# ==================================================================================

=head2 _one_tag

  Title    : _one_tag
  Usage    : $self->_one_tag
  Function : A method to store data from tags that occurs just once.
  Args     : 2 scalars:
             - reference to a scalar holding the value of the line to be parsed.
             - reference to a data structure to store the data for <$tag_name>
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : many
             Method(s) that this method calls   : _tag_processing_helper

=cut

sub _one_tag {

    my ($self, $line, $data_structure, $tag_name) = @_;

    $self->throw("Error:  Missing <$tag_name></$tag_name>.  Got: $$line\n\n")
        if $$line !~ /\<$tag_name/; 
    # check to see if $$line is in correct format.

    if ($$line =~ /<$tag_name\s?(.*?)\s?\/?>(.*?)<\/$tag_name>/) {

        $self->_tag_processing_helper($1, $data_structure, $tag_name, $2, 'one');
        # $1 = attributes $data_structure = to hold the parsed values
        # # $tag_name = name of the tag $2 = tag value 'one' = lets
        # _tag_processing_helper know that it was called from the
        # _one_tag method.

    } elsif ($$line =~ /<$tag_name\s?(.*?)\s?\/?>/) {

        $self->_tag_processing_helper($1, $data_structure, $tag_name, '', 'one');

    } else {
        $self->throw("Error:  Cannot parse this line: $$line\n\n");
    }

    $$line = $self->_readline;  # get the next line.

    return;

}
# ==================================================================================

=head2 _question_mark_tag

  Title    : _question_mark_tag
  Usage    : $self->_question_mark_tag
  Function : Parses values from tags that occurs zero or one time. ie: tag_name?
  Args     : 3 scalars:
             - reference to a scalar holding the value of the line to be parsed.
             - reference to a data structure to store the data for <$tag_name>
             - scalar holding the name of the tag.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : many.
             Method(s) that this method calls   : _tag_processing_helper


=cut

sub _question_mark_tag {

    my ($self, $line, $data_structure, $tag_name) = @_;

    if ($$line =~ /<$tag_name\s?(.*?)\s?>(.*?)<\/$tag_name>/) {
        $self->_tag_processing_helper($1, $data_structure, $tag_name, $2, 'question mark');
        $$line = $self->_readline;
    }

    return;

}
# ==================================================================================

=head2 _star_tag

  Title    : _star_tag
  Usage    : $self->_star_tag
  Function : Parses values from tags that occur zero or more times. ie: tag_name*
  Args     : 3 scalars:
             - reference to a scalar holding the value of the line to be parsed.
             - reference to a data structure to store the data for <$tag_name>
             - scalar holding the name of the tag.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : many.
             Method(s) that this method calls   : _tag_processing_helper

=cut

sub _star_tag {

    my ($self, $line, $data_structure, $tag_name) = @_;

    #print "tag_name: $tag_name\n";
    while ($$line =~ /<$tag_name\s?(.*?)\s?>(.*?)<\/$tag_name>/) {
        $self->_tag_processing_helper
            ($1, $data_structure, $tag_name, $2, 'star');
        # The tag and attribute values are stored within
        # $$data_structure within the _tag_processing_helper method.
        $$line = $self->_readline;
    }
    #if ($tag_name eq 'qualifier'){
    #       print "this one:\n";
    #       print Data::Dumper->Dump([$data_structure]); exit;
    #}

    return;

}
# ==================================================================================

=head2 _plus_tag

  Title    : _plus_tag
  Usage    : $self->_plus_tag
  Function : Handles 'plus' tags (tags that occur one or more times).  tag_name+
  Args     : 3 scalars:
             - reference to a scalar holding the value of the line to be parsed.
             - reference to a data structure to store the data for <$tag_name>
             - scalar holding the name of the tag.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : many.
             Method(s) that this method calls   : _star_tag

=cut

sub _plus_tag {

    my ($self, $line, $data_structure, $tag_name) = @_;

    if ($$line =~ /<$tag_name\s?(.*?)\s?>(.*?)<\/$tag_name>/) {

        # Store value of the first occurence of $tag_name.
        # All subsequent values, if any, will be stored in the method _star_tag.
        $self->_tag_processing_helper($1, $data_structure, $tag_name, $2, 'plus');


        # If the flow gets within this block, we've already determined
        # that there's at least one of <$tag_name> Are there more?  To
        # answer this, we could just treat the tag as a * tag now
        # (zero or more).  We've already determined that it's NOT
        # zero, so how many more?  Thus, call _star_tag.
        $$line = $self->_readline;
        $self->_star_tag($line, $data_structure, $tag_name);


    } else {
        $self->throw("Error:  Missing <$tag_name></$tag_name>.  Got: $$line\n\n");
    }

    return;

}
# ==================================================================================

=head2 _helper_store_attribute_list

  Title    : _helper_store_attribute_list
  Usage    : $self->_helper_store_attribute_list
  Function : A helper method used to store the attributes from
             the tags into the data structure.
  Args     : 2 scalars:
             - scalar holding the attribute values to be parsed.
             - reference to a data structure to store the data between the 2 tags.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : Many.
             Method(s) that this method call(s) : None.

=cut

sub _helper_store_attribute_list {

    my ($self, $attribute_line, $data_structure) = @_;

    my %attribs = ($attribute_line =~ /(\w+)\s*=\s*"([^"]*)"/g);

    my $attribute_list;
    for my $key (keys %attribs) {
        # print "\tkey: $key , value: $attribs{$key}\n";
        ###$$data_structure->{$key} = $attribs{$key};           # <- The ORIGINAL.
        push @{$$data_structure->{$key}}, $attribs{$key};
        # Now, store them in an array because there may be > 1 tag, thus
        # > 1 attribute of the same name.
        # Doing this has made it necessary to change the _store_seqs method.
        # ie: Change $bio_sequence->{'molecule_type'};
        # to
        # $bio_sequence->{'molecule_type'}->[0];
    }

    return;

}
# ==================================================================================

=head2 _store_seqs

  Title    : _store_seqs
  Usage    : $self->_store_seqs
  Function : This method is called once in the life time of the script.
             It stores the data parsed from the agave xml file into
             the Bio::Seq object.
  Args     : None.
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method : next_seq
             Method(s) that this method calls   : None.

=cut

sub _store_seqs {

    my ($self) = @_;


    for my $sciobj (@{$self->{'sciobj'}}) {

        ### $sciobj = $self->{'sciobj'};                # The root node.


        for my $contig (@{$sciobj->{'contig'}}) { # Each contig has a fragment order.

            for my $fragment_order (@{$contig->{'fragment_order'}}) { # Each fragment order has a fragment_orientation.

                for my $fragment_orientation (@{$fragment_order->{'fragment_orientation'}}) {
                    # Each fragment_orientation contain 1 bio sequence.

                    my $bio_sequence = $fragment_orientation->{'bio_sequence'}; # <bio_sequence> contains all the
                    # interesting stuff:

                    my $sequence         = $bio_sequence->{'sequence'};
                    my $accession_number = $bio_sequence->{'sequence_id'}->[0]; # also use for primary_id
                    my $organism         = $bio_sequence->{'organism'};
                    my $description      = $bio_sequence->{'description'};
                    my $molecule_type    = $bio_sequence->{'molecule_type'}->[0];

                    my $primary_seq = Bio::PrimarySeq->new(
                                                           -id       => $accession_number,
                                                           -alphabet => $molecule_type,
                                                           -seq      => $sequence,
                                                           -desc     => $description,
                                                          );

                    my $seq = Bio::Seq->new (
                                             -display_id       => $accession_number,
                                             -accession_number => $accession_number,
                                             -primary_seq      => $primary_seq,
                                             -seq              => $sequence,
                                             -description      => $description,
                                            );

                    my $organism_name = $bio_sequence->{organism_name}->[0];
                    if (defined $organism_name) {

                        my @classification = split(' ', $organism_name);
                        my $species = Bio::Species->new();
                        $species->classification(@classification);
                        $seq->species($species);
                    }
                    # Pull out the keywords: $keywords is an array ref.

                    my $keywords = $bio_sequence->{keyword};
                    my %key_to_value;

                    for my $keywords (@$keywords) {
                        # print "keywords: $keywords\n";
                        my @words = split(':', $keywords);
                        for (my $i = 0; $i < scalar @words - 1; $i++) {
                            if ($i % 2 == 0) {
                                my $j = $i; $j++;
                                # print "$words[$i] , $words[$j]\n";
                                $key_to_value{$words[$i]} = $words[$j];
                            }
                        }
                        # print Data::Dumper->Dump([%key_to_value]);
                        my $reference = Bio::Annotation::Reference->
                            new(-authors => $key_to_value{authors},
                                -title => $key_to_value{title},
                                -database => $key_to_value{database},
                                -pubmed => $key_to_value{pubmed},
                               );
                        $seq->annotation->add_Annotation('reference', $reference);

                    }           # close for my $keywords


                    #  print Data::Dumper->Dump([$bio_sequence]); print "here\n"; exit;
                    if (defined $bio_sequence->{'sequence_map'}) {

                        for my $sequence_map (@{$bio_sequence->{'sequence_map'}}) {

                            # print Data::Dumper->Dump([$sequence_map]); print "here\n"; exit;

                            my $label = $sequence_map->{label};

                            if (defined $sequence_map->{annotations} &&
                                ref($sequence_map->{annotations}) eq 'HASH') {

                                # Get the sequence features (ie genes, exons, etc) from this $sequence_map
                                for my $seq_feature (@{$sequence_map->{'annotations'}->{'seq_feature'}}) {

                                    # print Data::Dumper->Dump([$seq_feature]); exit;
                                    my $seq_location     = $seq_feature->{'seq_location'};
                                    my $start_coord      = $seq_feature->{'least_start'}->[0];
                                    my $feature_type     = $seq_feature->{'feature_type'}->[0];
                                    my $end_coord        = $seq_feature->{'greatest_end'}->[0];
                                    my $is_on_complement = $seq_feature->{'is_on_complement'}->[0];

                                    # Specify the coordinates and the tag for this seq feature.
                                    # print "Primary Tag for this SeqFeature: $feature_type\n";
                                    my $feat = Bio::SeqFeature::Generic->
                                        new(
                                            -start       => $start_coord,
                                            -end         => $end_coord,
                                            -primary_tag => $feature_type,
                                           );


                                    if (defined $seq_feature->{'qualifier'} &&
                                        ref($seq_feature->{'qualifier'}) eq 'ARRAY') {

                                        for my $feature (@{$seq_feature->{'qualifier'}}) {

                                            my $value = $feature->{'qualifier'};
                                            my $feature_type = $feature->{'qualifier_type'};

                                            for (my $i = 0;
                                                 $i < scalar @{$value};
                                                 $i++) {
                                                $feat->add_tag_value(
                                                                     $feature_type->[$i] => $value->[$i]
                                                                    );
                                            } # close the for loop

                                        }

                                    } # close if (defined $seq_feature->...


                                    $seq->add_SeqFeature($feat);


                                } # close for my $seq_feature (@{$sequence_map->...


                            }   # close if (defined $sequence_map->{annotations} &&


                        }       # close for my $sequence_map (@{$bio_sequence->{'sequence_map'}}){

                    }           # close if (defined $bio_sequence->{'sequence_map'}){


                    # This is where the Bio::Seq objects are stored:
                    push @{$self->{'sequence_objects'}}, $seq;


                }               # close for my $fragment_orientation


            }                   # close for my $fragment_order


        }                       # close for my $contig


    }                           # close for my $sciobj

    # Flag is set so that we know that the sequence objects are now stored in $self.
    $self->{'seqs_stored'} = 1;

    return;

}
# ==================================================================================

=head2 next_seq

        Title    : next_seq
        Usage    : $seq = $stream->next_seq()
        Function : Returns the next sequence in the stream.
        Args     : None.
        Returns  : Bio::Seq object

Method is called from the script.  Method(s) that this method calls:
_store_seqs (only once throughout the life time of script execution).


=cut

sub next_seq {

    my ($self) = @_;

    # convert agave to genbank/fasta/embl whatever.

    $self->_store_seqs if $self->{'seqs_stored'} == 0;

    $self->throw("Error: No Bio::Seq objects stored yet!\n\n")
        if !defined $self->{'sequence_objects'}; # This should never occur...

    if (scalar @{$self->{'sequence_objects'}} > 0) {
        return shift @{$self->{'sequence_objects'}};
    } else {
        # All done.  Nothing more to parse.
        # print "returning nothing!\n";
        return;
    }


}
# ==================================================================================

=head2 next_primary_seq

  Title   : next_primary_seq
  Usage   : $seq = $stream->next_primary_seq()
  Function: returns the next primary sequence (ie no seq_features) in the stream
  Returns : Bio::PrimarySeq object
  Args    : NONE

=cut

sub next_primary_seq {
    my $self=shift;
    return 0;
}
# ==================================================================================

=head2 write_seq

  Title   : write_seq
  Usage   : Not Yet Implemented! $stream->write_seq(@seq)
  Function: writes the $seq object into the stream
  Returns : 1 for success and 0 for error
  Args    : Bio::Seq object

=cut

sub write_seq {

    # Convert the Bio::Seq object(s) to AGAVE xml file.

    my ($self,@seqs) = @_;

    foreach my $seq ( @seqs ) {
        $self->_write_each_record( $seq ); # where most of the work actually takes place.
    }

    return;

}
# ==================================================================================

=head2 _write_each_record

  Title   : _write_each_record
  Usage   : $agave->_write_each_record( $seqI )
  Function: change data into agave format
  Returns : NONE
  Args    : Bio::SeqI object

=cut

sub  _write_each_record {
    my ($self,$seq) = @_;

    # $self->{'file'} =~ s/>//g;
    my $output = IO::File->new(">" . $self->{'file'});
    my $writer = XML::Writer->new(OUTPUT => $output,
                                 NAMESPACES => 0,
                                 DATA_MODE => 1,
                                 DATA_INDENT => 2 ) ;

    $writer->xmlDecl("UTF-8");
    $writer->doctype("sciobj", '', "sciobj.dtd");
    $writer ->startTag('sciobj',
                       'version', '2',
                       'release', '2');

    $writer->startTag('contig', 'length', $seq->length);
    my $annotation = $seq ->annotation;
    # print "annotation: $annotation\n"; exit;  Bio::Annotation::Collection=HASH(0x8112e6c)
    if ( $annotation->get_Annotations('dblink') ) {
        # used to be $annotation->each_DBLink, but Bio::Annotation::Collection::each_DBLink
        # is now replaced with get_Annotations('dblink')
        my $dblink = $annotation->get_Annotations('dblink')->[0] ;

        $writer ->startTag('db_id',
                           'id', $dblink->primary_id ,
                           'db_code', $dblink->database );
    } else {
        $writer ->startTag('db_id',
                           'id', $seq->display_id ,
                           'db_code', 'default' );
    }
    $writer ->endTag('db_id') ;


    $writer->startTag('fragment_order');
    $writer->startTag('fragment_orientation');

    ##start bio_sequence
    ####my $organism = $seq->species->genus . " " . $seq->species->species;
    $writer ->startTag('bio_sequence',
                       'sequence_id', $seq->display_id,
                       'seq_length', $seq->length,
                       # 'molecule_type', $seq->moltype, # deprecated
                       'molecule_type', $self->alphabet,
                       #'organism_name', $organism
                      );

    # my $desc = $seq->{primary_seq}->{desc};
    # print "desc: $desc\n"; exit;
    # print Data::Dumper->Dump([$seq]);  exit;
    ##start db_id under bio_sequence
    $annotation = $seq ->annotation;
    # print "annotation: $annotation\n"; exit;  Bio::Annotation::Collection=HASH(0x8112e6c)
    if ( $annotation->get_Annotations('dblink') ) {
        # used to be $annotation->each_DBLink, but Bio::Annotation::Collection::each_DBLink
        # is now replaced with get_Annotations('dblink')
        my $dblink = $annotation->get_Annotations('dblink')->[0] ;

        $writer ->startTag('db_id',
                           'id', $dblink->primary_id ,
                           'db_code', $dblink->database );
    } else {
        $writer ->startTag('db_id',
                           'id', $seq->display_id ,
                           'db_code', 'default' );
    }
    $writer ->endTag('db_id') ;

    ##start note
    my $note = "" ;
    foreach my $comment ( $annotation->get_Annotations('comment') ) {
        # used to be $annotations->each_Comment(), but that's now been replaced
        # with get_Annotations()
        # $comment is a Bio::Annotation::Comment object
        $note .= $comment->text() . "\n";
    }

    $writer ->startTag('note');
    $writer ->characters( $note ) ;
    $writer ->endTag('note');

    ##start description
    $writer ->startTag('description');

    # $writer ->characters( $annotation->get_Annotations('description') ) ;
    # used to be $annotations->each_description(), but that's now been
    # replaced with get_Annotations.
    # Simon added this: this is the primary_seq's desc (the DEFINITION tag in a genbank file)
    $writer->characters($seq->{primary_seq}->{desc});
    $writer ->endTag('description');

    ##start keywords
    foreach my $genename ( $annotation->get_Annotations('gene_name') ) {
        # used to be $annotations->each_gene_name, but that's now been
        # replaced with get_Annotations()
        $writer ->startTag('keyword');
        $writer ->characters( $genename ) ;
        $writer ->endTag('keyword');
    }


    foreach my $ref ( $annotation->get_Annotations('reference') ) {
        # used to be $annotation->each_Reference, but
        # that's now been replaced with get_Annotations('reference');
        # link is a Bio::Annotation::Reference object
        $writer ->startTag('keyword');
        # print Data::Dumper->Dump([$ref]); exit;
        my $medline  = $ref->medline || 'null';
        my $pubmed   = $ref->pubmed || 'null';
        my $database = $ref->database || 'null';
        my $authors  = $ref->authors || 'null';
        my $title    = $ref->title || 'null';


        $writer ->characters( 'medline:' . "$medline" . ':' . 'pubmed:' .
                              "$pubmed" . ':' . 'database:' . "$database" .
                              ':' .'authors:' . "$authors" . ':' . 'title:' . "$title" ) ;
        $writer ->endTag('keyword');
    }

    ## start sequence
    $writer ->startTag('sequence');
    $writer ->characters( $seq->seq ) ;
    $writer ->endTag('sequence');

    ## start xrefs
    $writer ->startTag('xrefs');
    foreach my $link ( $annotation->get_Annotations('dblink') ) {
        # link is a Bio::Annotation::DBLink object
        $writer ->startTag('db_id',
                           'db_code', $link->database,
                           'id', $link->primary_id);
        $writer ->characters( $link->comment ) ;
        $writer ->endTag('db_id');
    }
    $writer ->endTag('xrefs') ;

    ##start sequence map
    ##we can not use :  my @feats = $seq->all_SeqFeatures;
    ##rather, we use top_SeqFeatures() to keep the tree structure
    my @feats = $seq->top_SeqFeatures ;

    my $features;

    ##now we need cluster top level seqfeature by algorithm
    my $maps;
    foreach my $feature (@feats) {
        my $map_type = $feature ->source_tag;
        push (@{$maps->{ $map_type }}, $feature);
    }

    ##now we enter each sequence_map
    foreach my $map_type (keys  %$maps ) {
        $writer->startTag('sequence_map',
                          'label', $map_type );
        $writer->startTag('annotations');
        # the original author accidently entered 'annotation' instead of 'annotations'

        foreach my $feature ( @{$maps->{ $map_type }} ) {
            $self->_write_seqfeature( $feature, $writer ) ;
        }

        $writer->endTag('annotations');
        $writer->endTag('sequence_map');
    }

    $writer->endTag('bio_sequence');
    $writer->endTag('fragment_orientation');
    $writer->endTag('fragment_order');
    $writer->endTag('contig');
    $writer->endTag('sciobj');

}
# ==================================================================================

=head2 _write_seqfeature

  Usage   : $agave->_write_each_record( $seqfeature, $write )
  Function: change seeqfeature data into agave format
  Returns : NONE
  Args    : Bio::SeqFeature object and XML::writer object

=cut

sub _write_seqfeature{

    my ($self,$seqf, $writer) = @_;

    ##now enter seq feature
    $writer ->startTag('seq_feature',
                       'feature_type', $seqf->primary_tag() );

    my $strand = $seqf->strand();
    $strand = 0 if !defined $strand;
    # $strand == 1 ? 'false' : 'true';
    my $is_on_complement;
    if ($strand == 1) {
        $is_on_complement = 'true';
    } else {
        $is_on_complement = 'false';
    }

    # die Data::Dumper->Dump([$seqf]) if !defined $strand;
    $writer ->startTag('seq_location',
                       'lease_start', $seqf->start(),
                       'greatest_end', $seqf->end(),
                       # 'is_on_complement', $seqf->strand() == 1 ? 'false' : 'true') ;
                       'is_on_complement' , $is_on_complement);
    # is_on_complement: is the feature found on the complementary
    # strand (true) or not (false)?
    $writer ->endTag('seq_location');

    ##enter qualifier
    foreach my $tag ( $seqf->all_tags() ) {
        $writer ->startTag('qualifier',
                           'qualifier_type', $tag);
        $writer ->characters( $seqf->each_tag_value($tag) ) ;
        $writer ->endTag('qualifier');
    }

    ##now recursively travel the seqFeature
    foreach my $subfeat ( $seqf->sub_SeqFeature ) {
        $self->_write_seqfeature( $subfeat, $writer ) ;
    }

    $writer->endTag('seq_feature');

    return;

}
# ==================================================================================

=head2 _filehandle

  Title   : _filehandle
  Usage   : $obj->_filehandle($newval)
  Function:
  Example :
  Returns : value of _filehandle
  Args    : newvalue (optional)

=cut

sub _filehandle{

    my ($obj,$value) = @_;
    if ( defined $value) {
        $obj->{'_filehandle'} = $value;
    }
    return $obj->{'_filehandle'};

}
# ==================================================================================

=head2 throw

  Title    : throw
  Usage    : $self->throw;
  Function : Throw's error message.  Calls SeqIO's throw method.
  Args     : Array of string(s), holding error message(s).
  Returns  : Nothing.
  Note     : Method(s) that call(s) this method: many.
             Method(s) that this method calls: Bio::SeqIO's throw method.

=cut

sub throw {

    my ($self, @s) = @_;
    my $string = "[$.]" . join('', @s);
    $self->SUPER::throw($string);
    return;

}

1;
