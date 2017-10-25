#
# BioPerl module for Bio::SeqIO::table
#
# Please direct questions and support issues to <bioperl-l@bioperl.org> 
#
# Cared for by Hilmar Lapp
#
# You may distribute this module under the same terms as perl itself.
# Refer to the Perl Artistic License (see the license accompanying this
# software package, or see http://www.perl.com/language/misc/Artistic.html)
# for the terms under which you may use, modify, and redistribute this module.
#
# THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
# MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#

# POD documentation - main docs before the code

=head1 NAME

Bio::SeqIO::table - sequence input/output stream from a delimited table

=head1 SYNOPSIS

  # It is probably best not to use this object directly, but
  # rather go through the SeqIO handler system. Go:

  $stream = Bio::SeqIO->new(-file => $filename, -format => 'table');

  while ( my $seq = $stream->next_seq() ) {
	# do something with $seq
  }

=head1 DESCRIPTION

This class transforms records in a table-formatted text file into
Bio::Seq objects.

A table-formatted text file of sequence records for the purposes of
this module is defined as a text file with each row corresponding to a
sequence, and the attributes of the sequence being in different
columns. Columns are delimited by a common delimiter, for instance tab
or comma.

The module permits specifying which columns hold which type of
annotation. The semantics of certain attributes, if present, are
pre-defined, e.g., accession number and sequence. Additional
attributes may be added to the annotation bundle.

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

Bug reports can be submitted via email or the web:

  https://github.com/bioperl/bioperl-live/issues

=head1 AUTHOR - Hilmar Lapp

Email hlapp at gmx.net

=head1 APPENDIX

The rest of the documentation details each of the object
methods. Internal methods are usually preceded with a _

=cut

# Let the code begin...

package Bio::SeqIO::table;
use strict;

use Bio::Species;
use Bio::Seq::SeqFactory;
use Bio::Annotation::Collection;
use Bio::Annotation::SimpleValue;

use base qw(Bio::SeqIO);

=head2 new

 Title   : new
 Usage   : $stream = Bio::SeqIO->new(-file => $filename, -format => 'table')
 Function: Returns a new seqstream
 Returns : A Bio::SeqIO stream for a table format
 Args    : Named parameters:

 -file              Name of file to read
 -fh                Filehandle to attach to
 -comment           Leading character(s) introducing a comment line
 -header            the number of header lines to skip; the first
                    non-comment header line will be used to obtain
                    column names; column names will be used as the
                    default tags for attaching annotation.
 -delim             The delimiter for columns as a regular expression;
                    consecutive occurrences of the delimiter will
                    not be collapsed.
 -display_id        The one-based index of the column containing
                    the display ID of the sequence
 -accession_number  The one-based index of the column
                    containing the accession number of the sequence
 -seq               The one-based index of the column containing
                    the sequence string of the sequence
 -species           The one-based index of the column containing the
                    species for the sequence record; if not a
                    number, will be used as the static species
                    common to all records
 -annotation        If provided and a scalar (but see below), a
                    flag whether or not all additional columns are
                    to be preserved as annotation, the tags used
                    will either be 'colX' if there is no column
                    header and where X is the one-based column
                    index, and otherwise the column headers will be
                    used as tags;

                    If a reference to an array, or a square
                    bracket-enclosed string of comma-delimited
                    values, only those columns (one-based index)
                    will be preserved as annotation, tags as before;

                    If a reference to a hash, or a curly
                    braces-enclosed string of comma-delimited key
                    and value pairs in alternating order, the keys
                    are one-based column indexes to be preserved,
                    and the values are the tags under which the
                    annotation is to be attached; if not provided or
                    supplied as undef, no additional annotation will
                    be preserved.
 -colnames          A reference to an array of column labels, or a
                    string of comma-delimited labels, denoting the
                    columns to be converted into annotation; this is
                    an alternative to -annotation and will be
                    ignored if -annotation is also supplied with a
                    valid value.
 -trim              Flag determining whether or not all values should
                    be trimmed of leading and trailing white space
                    and double quotes

 Additional arguments may be used to e.g. set factories and
 builders involved in the sequence object creation (see the
 POD of Bio::SeqIO).

=cut

sub _initialize {
    my($self,@args) = @_;

    # chained initialization
    $self->SUPER::_initialize(@args);

    # our own parameters
    my ($cmtchars,
        $header,
        $delim,
        $display_id,
        $accnr,
        $seq,
        $taxon,
        $useann,
        $colnames,
        $trim) =
            $self->_rearrange([qw(COMMENT
                                  HEADER
                                  DELIM
                                  DISPLAY_ID
                                  ACCESSION_NUMBER
                                  SEQ
                                  SPECIES
                                  ANNOTATION
                                  COLNAMES
                                  TRIM)
                              ], @args);

    # store options and apply defaults
    $self->comment_char(defined($cmtchars) ? $cmtchars : "#")
        if (!defined($self->comment_char)) || defined($cmtchars);
    $self->delimiter(defined($delim) ? $delim : "\t")
        if (!defined($self->delimiter)) || defined($delim);
    $self->header($header) if defined($header);
    $self->trim_values($trim) if defined($trim);

    # attribute columns
    my $attrs = {};
    $attrs->{-display_id} = $display_id if defined($display_id);
    $attrs->{-accession_number} = $accnr if defined($accnr);
    $attrs->{-seq} = $seq if defined($seq);
    if (defined($taxon)) {
        if (ref($taxon) || ($taxon =~ /^\d+$/)) {
            # either a static object, or a column reference
            $attrs->{-species} = $taxon;
        } else {
            # static species as a string
            $attrs->{-species} = Bio::Species->new(
                -classification => [reverse(split(' ',$taxon))]);
        }
    }
    $self->attribute_map($attrs);

    # annotation columns, if any
    if ($useann && !ref($useann)) {
        # it's a scalar; check whether this is in fact an array or
        # hash as a string rather than just a flag
        if ($useann =~ /^\[(.*)\]$/) {
            $useann = [split(/[,;]/,$1)];
        } elsif ($useann =~ /^{(.*)}$/) {
            $useann = {split(/[,;]/,$1)};
        } # else it is probably indeed just a flag
    }
    if (ref($useann)) {
        my $ann_map;
        if (ref($useann) eq "ARRAY") {
            my $has_header = ($self->header > 0);
            $ann_map = {};
            foreach my $i (@$useann) {
                $ann_map->{$i} = $has_header ? undef : "col$i";
            }
        } else {
            # no special handling necessary
            $ann_map = $useann;
        }
        $self->annotation_map($ann_map);
    } else {
        $self->keep_annotation($useann || $colnames);
        # annotation columns, if any
        if ($colnames && !ref($colnames)) {
            # an array as a string
            $colnames =~ s/^\[(.*)\]$/$1/;
            $colnames = [split(/[,;]/,$colnames)];
        }
        $self->annotation_columns($colnames) if ref($colnames);
    }

    # make sure we have a factory defined
    if(!defined($self->sequence_factory)) {
	$self->sequence_factory(
            Bio::Seq::SeqFactory->new(-verbose => $self->verbose(),
                                      -type => 'Bio::Seq::RichSeq'));
    }
}

=head2 next_seq

 Title   : next_seq
 Usage   : $seq = $stream->next_seq()
 Function: returns the next sequence in the stream
 Returns : Bio::Seq::RichSeq object
 Args    :

=cut

sub next_seq {
    my $self = shift;

    # skip until not a comment and not an empty line
    my $line_ok = $self->_next_record();

    # if there is a header but we haven't read past it yet then do so now
    if ($line_ok && (! $self->_header_skipped) && $self->header) {
        $line_ok = $self->_parse_header();
        $self->_header_skipped(1);
    }

    # return if we reached end-of-file
    return unless $line_ok;

    # otherwise, parse the record

    # split into columns
    my @cols = $self->_get_row_values();
    # trim leading and trailing whitespace and quotes if desired
    if ($self->trim_values) {
        for(my $i = 0; $i < scalar(@cols); $i++) {
            if ($cols[$i]) {
                # trim off whitespace
                $cols[$i] =~ s/^\s+//;
                $cols[$i] =~ s/\s+$//;
                # trim off double quotes
                $cols[$i] =~ s/^"//;
                $cols[$i] =~ s/"$//;
            }
        }
    }

    # assign values for columns in the attribute map
    my $attrmap = $self->_attribute_map;
    my %params = ();
    foreach my $attr (keys %$attrmap) {
        if ((!ref($attrmap->{$attr})) && ($attrmap->{$attr} =~ /^\d+$/)) {
            # this is a column index, add to instantiation parameters
            $params{$attr} = $cols[$attrmap->{$attr}];
        } else {
            # not a column index; we assume it's a static value
            $params{$attr} = $attrmap->{$attr};
        }
    }

    # add annotation columns to the annotation bundle
    my $annmap = $self->_annotation_map;
    if ($annmap && %$annmap) {
        my $anncoll = Bio::Annotation::Collection->new();
        foreach my $col (keys %$annmap) {
            next unless $cols[$col]; # skip empty columns!
            $anncoll->add_Annotation(
                Bio::Annotation::SimpleValue->new(-value  => $cols[$col],
                                                  -tagname=> $annmap->{$col}));
        }
        $params{'-annotation'} = $anncoll;
    }

    # ask the object builder to add the slots that we've gathered
    my $builder = $self->sequence_builder();
    $builder->add_slot_value(%params);
    # and instantiate the object
    my $seq = $builder->make_object();

    # done!
    return $seq;
}

=head2 comment_char

 Title   : comment_char
 Usage   : $obj->comment_char($newval)
 Function: Get/set the leading character(s) designating a line as
           a comment-line.
 Example :
 Returns : value of comment_char (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub comment_char{
    my $self = shift;

    return $self->{'comment_char'} = shift if @_;
    return $self->{'comment_char'};
}

=head2 header

 Title   : header
 Usage   : $obj->header($newval)
 Function: Get/set the number of header lines to skip before the
           rows containing actual sequence records.

           If set to zero or undef, means that there is no header and
           therefore also no column headers.

 Example :
 Returns : value of header (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub header{
    my $self = shift;

    return $self->{'header'} = shift if @_;
    return $self->{'header'};
}

=head2 delimiter

 Title   : delimiter
 Usage   : $obj->delimiter($newval)
 Function: Get/set the column delimiter. This will in fact be
           treated as a regular expression. Consecutive occurrences
           will not be collapsed to a single one.

 Example :
 Returns : value of delimiter (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub delimiter{
    my $self = shift;

    return $self->{'delimiter'} = shift if @_;
    return $self->{'delimiter'};
}

=head2 attribute_map

 Title   : attribute_map
 Usage   : $obj->attribute_map($newval)
 Function: Get/set the map of sequence object initialization
           attributes (keys) to one-based column index.

           Attributes will usually need to be prefixed by a dash, just
           as if they were passed to the new() method of the sequence
           class.

 Example :
 Returns : value of attribute_map (a reference to a hash)
 Args    : on set, new value (a reference to a hash or undef, optional)


=cut

sub attribute_map{
    my $self = shift;

    # internally we store zero-based maps - so we need to convert back
    # and forth here
    if (@_) {
        my $arg = shift;
        # allow for and protect against undef
        return delete $self->{'_attribute_map'} unless defined($arg);
        # copy to avoid side-effects
        my $attr_map = {%$arg};
        foreach my $key (keys %$attr_map) {
            if ((!ref($attr_map->{$key})) && ($attr_map->{$key} =~ /^\d+$/)) {
                $attr_map->{$key}--;
            }
        }
        $self->{'_attribute_map'} = $attr_map;
    }
    # there may not be a map
    return unless exists($self->{'_attribute_map'});
    # we need to copy in order not to override the stored map!
    my %attr_map = %{$self->{'_attribute_map'}};
    foreach my $key (keys %attr_map) {
        if ((!ref($attr_map{$key})) && ($attr_map{$key} =~ /^\d+$/)) {
            $attr_map{$key}++;
        }
    }
    return \%attr_map;
}

=head2 annotation_map

 Title   : annotation_map
 Usage   : $obj->annotation_map($newval)
 Function: Get/set the mapping between one-based column indexes
           (keys) and annotation tags (values).

           Note that the map returned by this method may change after
           the first next_seq() call if the file contains a column
           header and no annotation keys have been predefined in the
           map, because upon reading the column header line the tag
           names will be set automatically.

           Note also that the map may reference columns that are used
           as well in the sequence attribute map.

 Example :
 Returns : value of annotation_map (a reference to a hash)
 Args    : on set, new value (a reference to a hash or undef, optional)


=cut

sub annotation_map{
    my $self = shift;

    # internally we store zero-based maps - so we need to convert back
    # and forth here
    if (@_) {
        my $arg = shift;
        # allow for and protect against undef
        return delete $self->{'_annotation_map'} unless defined($arg);
        # copy to avoid side-effects
        my $ann_map = {%$arg};
        # make sure we sort the keys numerically or otherwise we may
        # clobber a key with a higher index
        foreach my $key (sort { $a <=> $b } keys(%$ann_map)) {
            $ann_map->{$key-1} = $ann_map->{$key};
            delete $ann_map->{$key};
        }
        $self->{'_annotation_map'} = $ann_map;
        # also make a note that we want to keep annotation
        $self->keep_annotation(1);
    }
    # there may not be a map
    return unless exists($self->{'_annotation_map'});
    # we need to copy in order not to override the stored map!
    my %ann_map = %{$self->{'_annotation_map'}};
    # here we need to sort numerically in reverse order ...
    foreach my $key (sort { $b <=> $a } keys(%ann_map)) {
        $ann_map{$key+1} = $ann_map{$key};
        delete $ann_map{$key};
    }
    return \%ann_map;
}

=head2 keep_annotation

 Title   : keep_annotation
 Usage   : $obj->keep_annotation($newval)
 Function: Get/set flag whether or not to keep values from
           additional columns as annotation.

           Additional columns are all those columns in the input file
           that aren't referenced in the attribute map.

 Example :
 Returns : value of keep_annotation (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub keep_annotation{
    my $self = shift;

    return $self->{'keep_annotation'} = shift if @_;
    return $self->{'keep_annotation'};
}

=head2 annotation_columns

 Title   : annotation_columns
 Usage   : $obj->annotation_columns($newval)
 Function: Get/set the names (labels) of the columns to be used for
           annotation.

           This is an alternative to using annotation_map. In order to
           have any effect, it must be set before the first call of
           next_seq(), and obviously there must be a header line (or
           row) too giving the column labels.

 Example :
 Returns : value of annotation_columns (a reference to an array)
 Args    : on set, new value (a reference to an array of undef, optional)


=cut

sub annotation_columns{
    my $self = shift;

    return $self->{'annotation_columns'} = shift if @_;
    return $self->{'annotation_columns'};
}

=head2 trim_values

 Title   : trim_values
 Usage   : $obj->trim_values($newval)
 Function: Get/set whether or not to trim leading and trailing
           whitespace off all column values.
 Example :
 Returns : value of trim_values (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub trim_values{
    my $self = shift;

    return $self->{'trim_values'} = shift if @_;
    return $self->{'trim_values'};
}

=head1 Internal methods

All methods with a leading underscore are not meant to be part of the
'official' API. They are for use by this module only, consider them
private unless you are a developer trying to modify this module.

=cut

=head2 _attribute_map

 Title   : _attribute_map
 Usage   : $obj->_attribute_map($newval)
 Function: Get only. Same as attribute_map, but zero-based indexes.

           Note that any changes made to the returned map will change
           the map used by this instance. You should know what you are
           doing if you modify the returned value (or if you call this
           method in the first place).

 Example :
 Returns : value of _attribute_map (a reference to a hash)
 Args    : none


=cut

sub _attribute_map{
    my $self = shift;

    return $self->{'_attribute_map'};
}

=head2 _annotation_map

 Title   : _annotation_map
 Usage   : $obj->_annotation_map($newval)
 Function: Get only. Same as annotation_map, but with zero-based indexes.

           Note that any changes made to the returned map will change
           the map used by this instance. You should know what you are
           doing if you modify the returned value (or if you call this
           method in the first place).

 Example :
 Returns : value of _annotation_map (a reference to a hash)
 Args    : none


=cut

sub _annotation_map{
    my $self = shift;

    return $self->{'_annotation_map'};
}

=head2 _header_skipped

 Title   : _header_skipped
 Usage   : $obj->_header_skipped($newval)
 Function: Get/set the flag whether the header was already
           read (and skipped) or not.
 Example :
 Returns : value of _header_skipped (a scalar)
 Args    : on set, new value (a scalar or undef, optional)


=cut

sub _header_skipped{
    my $self = shift;

    return $self->{'_header_skipped'} = shift if @_;
    return $self->{'_header_skipped'};
}

=head2 _next_record

 Title   : _next_record
 Usage   :
 Function: Navigates the underlying file to the next record.

           For row-based records in delimited text files, this will
           skip all empty lines and lines with a leading comment
           character.

           This method is here is to serve as a hook for other formats
           that conceptually also represent tables but aren't
           formatted as row-based text files.

 Example :
 Returns : TRUE if the navigation was successful and FALSE
           otherwise. Unsuccessful navigation will usually be treated
           as an end-of-file condition.
 Args    :


=cut

sub _next_record{
    my $self = shift;

    my $cmtcc = $self->comment_char;
    my $line = $self->_readline();

    # skip until not a comment and not an empty line
    while (defined($line)
           && (($cmtcc && ($line =~ /^\s*$cmtcc/))
               || ($line =~ /^\s*$/))) {
        $line = $self->_readline();
    }

    return $self->{'_line'} = $line;
}

=head2 _parse_header

 Title   : _parse_header
 Usage   :
 Function: Parse the table header and navigate past it.

           This method is called if the number of header rows has been
           specified equal to or greater than one, and positioned at
           the first header line (row). By default the first header
           line (row) is used for setting column names, but additional
           lines (rows) may be skipped too. Empty lines and comment
           lines do not count as header lines (rows).

           This method will call _next_record() to navigate to the
           next header line (row), if there is more than one header
           line (row). Upon return, the file is presumed to be
           positioned at the first record after the header.

           This method is here is to serve as a hook for other formats
           that conceptually also represent tables but aren't
           formatted as row-based text files.

           Note however that the only methods used to access file
           content or navigate the position are _get_row_values() and
           _next_record(), so it should usually suffice to override
           those.

 Example :
 Returns : TRUE if navigation past the header was successful and FALSE
           otherwise. Unsuccessful navigation will usually be treated
           as an end-of-file condition.
 Args    :


=cut

sub _parse_header{
    my $self = shift;

    # the first header line contains the column headers, see whether
    # we need them
    if ($self->keep_annotation) {
        my @colnames = $self->_get_row_values();
        # trim leading and trailing whitespace if desired
        if ($self->trim_values) {
            # trim off whitespace
            @colnames = map { $_ =~ s/^\s+//; $_ =~ s/\s+$//; $_; } @colnames;
            # trim off double quotes
            @colnames = map { $_ =~ s/^"//; $_ =~ s/"$//; $_; } @colnames;
        }
        # build or complete annotation column map
        my $annmap = $self->annotation_map || {};
        if (! %$annmap) {
            # check whether columns have been defined by name rather than index
            if (my $anncols = $self->annotation_columns) {
                # first sanity check: all column names must map
                my %colmap = map { ($_,1); } @colnames;
                foreach my $col (@$anncols) {
                    if (!exists($colmap{$col})) {
                        $self->throw("no such column labeled '$col'");
                    }
                }
                # now map to the column indexes
                %colmap = map { ($_,1); } @$anncols;
                for (my $i = 0; $i < scalar(@colnames); $i++) {
                    if (exists($colmap{$colnames[$i]})) {
                        $annmap->{$i+1} = $colnames[$i];
                    }
                }
            } else {
                # no columns specified, default to all non-attribute columns
                for (my $i = 0; $i < scalar(@colnames); $i++) {
                    $annmap->{$i+1} = $colnames[$i];
                }
                # subtract all attribute-referenced columns
                foreach my $attrcol (values %{$self->attribute_map}) {
                    if ((!ref($attrcol)) && ($attrcol =~ /^\d+$/)) {
                        delete $annmap->{$attrcol};
                    }
                }
            }
        } else {
            # fill in where the tag names weren't pre-defined
            for (my $i = 0; $i < scalar(@colnames); $i++) {
                if (exists($annmap->{$i+1}) && ! defined($annmap->{$i+1})) {
                    $annmap->{$i+1} = $colnames[$i];
                }
            }
        }
        $self->annotation_map($annmap);
    }

    # now read past the header
    my $header_lines = $self->header;
    my $line_ok = 1;
    while (defined($line_ok) && ($header_lines > 0)) {
        $line_ok = $self->_next_record();
        $header_lines--;
    }

    return $line_ok;
}

=head2 _get_row_values

 Title   : _get_row_values
 Usage   :
 Function: Get the values for the current line (or row) as an array in
           the order of columns.

           This method is here is to serve as a hook for other formats
           that conceptually also represent tables but aren't
           formatted as row-based text files.

 Example :
 Returns : An array of column values for the current row.
 Args    :


=cut

sub _get_row_values{
    my $self = shift;
    my $delim = $self->delimiter;
    my $line = $self->{'_line'};
    chomp($line);
    my @cols = split(/$delim/,$line);
    return @cols;
}

1;
