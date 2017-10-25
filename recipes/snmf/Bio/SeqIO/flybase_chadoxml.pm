#
# BioPerl module for Bio::SeqIO::flybase_chadoxml
#
# Peili Zhang   <peili@morgan.harvard.edu>
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::flybase_chadoxml - FlyBase variant of chadoxml with sequence output stream

=head1 SYNOPSIS

It is probably best not to use this object directly, but
rather go through the SeqIO handler system:

    $writer = Bio::SeqIO->new(-file => ">chado.xml",
                              -format => 'flybase_chadoxml');

    # assume you already have Sequence or SeqFeature objects
    $writer->write_seq($seq_obj);

    #after writing all seqs
    $writer->close_chadoxml();


=head1 DESCRIPTION

This is a simple subclass of L<Bio::SeqIO::chadoxml>; please see
its documentation for details.

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

=head1 AUTHOR - Peili Zhang

Email peili@morgan.harvard.edu

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

package Bio::SeqIO::flybase_chadoxml;
use strict;

use base 'Bio::SeqIO::chadoxml';

sub _initialize {
    my($self,%args) = @_;
    $self->SUPER::_initialize(%args);

    #default for standard chado is polypeptide
    $Bio::SeqIO::chadoxml::feattype_args2so{'CDS'} = 'protein';
    $Bio::SeqIO::chadoxml::cv_name{'sequence'} = 'SO';
    $Bio::SeqIO::chadoxml::cv_name{'relationship'} = 'relationship type';
    $Bio::SeqIO::chadoxml::cv_name{'feature_property'} = 'property type';

    return;
} 

=head2 return_ftype_hash

 Title    : return_ftype_hash
 Usage    : $obj->return_ftype_hash()
 Function : A simple hash where returning it has be factored out of the main
            code to allow subclasses to override it.
 Returns  : A hash that indicates what the name of the SO term is and what
            the name of the Sequence Ontology is in the cv table.
 Args     : The string that represents the SO term.
 Status   :

=cut

sub return_ftype_hash {
    my $self  = shift;
    my $ftype = shift;
    my %ftype_hash = ( "name" => $ftype,
                       "cv_id" => {"name" => $Bio::SeqIO::chadoxml::cv_name{'sequence'} });
    return %ftype_hash;
}

=head2 return_reltypename

 Title    : return_reltypename
 Usage    : $obj->return_reltypename
 Function : Return the appropriate relationship type name depending on the
            feature type (typically part_of, but derives_from for polypeptide).
 Returns  : A relationship type name.
 Args     : A SO type name.
 Status   :

=cut

sub return_reltypename {
    my $self   = shift;
    my $sftype = shift;

    my $reltypename;
    if ($sftype eq 'protein' || $sftype eq 'polypeptide') {
        $reltypename = 'producedby';
    } else {
        $reltypename = 'partof';
    }

    return $reltypename;
}

=head2 write_seq

 Title   : write_seq
 Usage   : $stream->write_seq(-seq=>$seq, -seq_so_type=>$seqSOtype,
                  -src_feature=>$srcfeature,
                  -src_feat_type=>$srcfeattype,
                  -nounflatten=>0 or 1,
                  -is_analysis=>'true' or 'false',
                  -data_source=>$datasource)
 Function: writes the $seq object (must be seq) into chadoxml.
 Returns : 1 for success and 0 for error
 Args     : A Bio::Seq object $seq, optional $seqSOtype, $srcfeature,
            $srcfeattype, $nounflatten, $is_analysis and $data_source.

Overrides Bio::SeqIO::chadoxml's write_seq method just to add an internal
close_chadoxml (mimics original use by FlyBase).

=cut

sub write_seq {
    my ($self, @argv) = @_;

    $self->SUPER::write_seq(@argv);

    $self->close_chadoxml;
    return 1;
}


1;
