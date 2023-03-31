#!/usr/bin/env python
from __future__ import print_function # python 2
import re
import sys
import json
import dustdas.fastahelper as fh


class GFFObject(object):
    @staticmethod
    def parse_gffline(gffline):
        """takes one line of a gff3 file and returns a dictionary"""
        if gffline.startswith("#"):
            pass
        else:
            gffcols = [g.strip() for g in gffline.split("\t")]

            res = {"seqid": gffcols[0],
                   "source": gffcols[1],
                   "type": gffcols[2],
                   "start": gffcols[3],
                   "end": gffcols[4],
                   "score": gffcols[5],
                   "strand": gffcols[6],
                   "phase": gffcols[7],
                   "attribute": gffcols[8],
                   }

            return res

    def __init__(self, gffline):
        d = GFFObject.parse_gffline(gffline)
        self.seqid = d["seqid"]
        self.source = d["source"]
        self.type = d["type"]
        self.start = d["start"]
        self.end = d["end"]
        self.score = self.parse_score(d) #d["score"]
        self.strand = d["strand"]
        self.phase = d["phase"]
        self.attribute = d["attribute"]
        self.attributes = [GFFAttribute(x.strip()) for x in  d["attribute"].split(";")]
        self.fasta_header = None
        self.fasta_sequence = None
    def parse_score(self, d):
        try:
            return float(d["score"])
        except ValueError:
            if d["score"] == ".":
                return "."
            else:
                raise ValueError
    def to_json(self, omit_fasta=False):
        if omit_fasta:
            res = dict()
            for k, v in self.__dict__.items():
                if k in ["fasta_header", "fasta_sequence"]:
                    pass
                else:
                    res[k] = v
            return json.dumps(res, default=lambda o: o.__dict__, sort_keys=True, indent=4)

        return json.dumps(self, default=lambda o: o.__dict__,
                          sort_keys=True, indent=4)

    def get_sequence(self, fastafile=None, fastadct=None, regex=None):
        """ Takes either a path to a fasta file or a pre-filled dictionary with header and sequence as items.
         If regex is present, it returns first header and sequence whose header matches that regex.
         If no regex is set it returns the header and sequence whose header matches self.seqname exactly.
        """
        if fastafile:
            for header, seq in fh.FastaParser.read_fasta(fasta=fastafile):
                if regex:
                    p = re.compile(regex)
                    m = p.match(header)
                    if m:
                        return header, seq
                else:
                    if header == self.seqid:
                        return header, seq
        elif fastadct:
            if regex:
                p = re.compile(regex)
                #print("debug", regex)
            for header, seq in fastadct.items():
                if regex:

                    m = p.match(header)
                    if m:
                        return header, seq
                else:
                    return header, fastadct[header]

    def attrib_filter_fun(self, tfun, targ, vfun, varg):
        """ Filters tags and values by given functions. First argument will always be mapped to attribute.tag (value),
         second to targ (varg).
         Eg tfun=lambda x,y: x==y, targ="ID" vfun=lambda x, y: x.startswith(y), varg="Chr1"
         returns True when object's attribute value for tag "ID" starts with "Chr1"
         """
        if tfun and vfun:
            for a in self.attributes:
                t = tfun(a.tag, targ)
                v = vfun(a.value, varg)
                if t and v:
                    return True

        ##if tfun and targ:
        # #  return  tfun(self.tag, targ)
        #if vfun and varg:
        #    return vfun(self.value, varg)
        return False  # TODO

    def attrib_filter(self, tag=None, value=None):
        if tag and not value:
            return [a for a in self.attributes if a.tag == tag]
        elif value and not tag:
            return [a for a in self.attributes if a.value == value]
        elif value and tag:
            return [a for a in self.attributes if a.value == value and a.tag == tag]
        else:
            print("needs tag or value to filter. returns list of matches", file=sys.stderr)

    def __repr__(self):
        return "{},{},{},{},{},{},{},{},{}".format(self.seqid, self.source, self.type, self.start, self.end, self.score, self.strand, self.phase, self.attributes)

    def attach_fasta(self, header, seq):
        self.fasta_header = header
        self.fasta_sequence = seq

    # short cuts
    def _get_attrib(self, attrib):
        def fun():
            try:
                res = self.attrib_filter(tag=attrib)[0].value
            except AttributeError:
                return None
            except IndexError:
                return None
            return res
        return fun()

    def get_Parent(self):
        """return one or multiple Parents"""
        return self._get_attrib("Parent")

    def get_Alias(self):
        """return one or multiple Alias'"""
        return self._get_attrib("Alias")


    def get_Note(self):
        """return one or multiple Notes"""
        return self._get_attrib("Note")


    def get_Dbxref(self):
        """return one or multiple Dbxrefs"""
        return self._get_attrib("Dbxref")

    def get_Ontology_term(self):
        """return one or multiple Ontology_terms"""
        return self._get_attrib("Ontology_term")


    def get_ID(self):
        """return ID"""
        return self._get_attrib("ID")[0] #ID should only be there once

    def get_Name(self):
        """return Name"""
        return self._get_attrib("Name")

    def get_Target(self):
        """return Target""" #TODO
        """Indicates the target of a nucleotide-to-nucleotide or protein-to-nucleotide alignment. 
        The format of the value is "target_id start end [strand]", 
        where strand is optional and may be "+" or "-". 
        If the target_id contains spaces, they must be escaped as hex escape %20."""
        return self._get_attrib("Target")


    def get_Gap(self): #TODO
        """The alignment of the feature to the target if the two are not collinear
        (e.g. contain gaps). The alignment format is taken
        from the CIGAR format described in the Exonerate documentation.
        See "THE GAP ATTRIBUTE" for a description of this format."""
        return self._get_attrib("Gap")

    def get_Derives_from(self): #TODO
        """Used to disambiguate the relationship between one feature and another
         when the relationship is a temporal one rather than a purely structural "part of" one.
        This is needed for polycistronic genes."""
        return self._get_attrib("Derives_from")

    def get_Is_circular(self):
        """return Is_circular"""
        return self._get_attrib("Is_circular")

    def embed_into(self, other):
        if not self.type in other.__dict__:
            other.__dict__[self.type] = [self] #??
        else:
            other.__dict__[self.type].append(self)


class GFFAttribute(object):
    def __init__(self, attribute_str):
        p = re.compile(r"""(.*)=(.*)""")
        m = p.match(attribute_str)
        if m:
           # r = [{"tag": m.groups()[0], "value": m.groups()[1]}]
            self.tag = m.groups()[0]
            self.value = [x for x in m.groups()[1].split(",")]
        else:
            self.tag = "wat"
            self.value = "wat"

    def __repr__(self):
        return "<tag:{},value:{}>".format(self.tag, self.value)


class GFFFile(object):

    @property
    def metadata(self):
        return self._metadata

    @property
    def path(self):
        return self._path

    @metadata.setter
    def metadata(self, str): #append, not overwrite
        self._metadata.append(str.strip().replace("##",""))

    def __init__(self, path):
        self._metadata = []
        self._path = path
        with fh.text_or_gzip_open(self._path, 'r') as f:
            for l in f:
                if l.strip() == "":
                    pass
                elif l.startswith("##"):
                    self.metadata = l # todo confusing
                elif l.startswith("#"):
                    pass

    def get_available_types(self):
        avail = {}
        for o in self.get_gff_objects():
            if o.type in avail:
                avail[o.type] += 1
            else:
                avail[o.type] = 1
        return avail

    def get_gff_objects(self):
        with fh.text_or_gzip_open(self._path, 'r') as f:
            for l in f:
                if l.strip() == "":
                    pass
                elif l.startswith("#"):
                    pass
                else:
                    obj = GFFObject(gffline=l.strip())
                    yield obj


def read_gff_file(infile):

    with fh.text_or_gzip_open(infile, 'r') as f:
        for l in f:
            if l.strip() == "":
                pass
            elif l.startswith("#"):
                pass
            else:
                obj = GFFObject(gffline=l)
                yield obj


"""

    From http://www.ensembl.org/info/website/upload/gff.html:
    
    seqname - name of the chromosome or scaffold; chromosome names can be given with or without the 'chr' prefix. 
              Important note: the seqname must be one used within Ensembl, 
              i.e. a standard chromosome name or an Ensembl identifier such as a scaffold ID, 
              without any additional content such as species or assembly. 
              See the example GFF output below.
    source - name of the program that generated this feature, or the data source (database or project name)
    feature - feature type name, e.g. Gene, Variation, Similarity
    start - Start position of the feature, with sequence numbering starting at 1.
    end - End position of the feature, with sequence numbering starting at 1.
    score - A floating point value.
    strand - defined as + (forward) or - (reverse).
    frame - One of '0', '1' or '2'. '0' indicates that the first base of the feature is the first base of a codon,
            '1' that the second base is the first base of a codon, and so on..
    attribute - A semicolon-separated list of tag-value pairs, 
                providing additional information about each feature. 
    
        ID, Name, Alias, Parent, Target, Gap, Derives_from, Note,
        Dbxref, Ontology_term, Is_circular
        Parent: groups exons into transcripts, transcripts into genes etc.
            A feature may have multiple parents.
        Target: Indicates the target of a nucleotide-to-nucleotide
            or protein-to-nucleotide alignment.
            The format of the value is "target_id start end [strand]",
            where strand is optional and may be "+" or "-".
        Gap: The alignment of the feature to the target if the two
            are not collinear (e.g. contain gaps).
            The alignment format is taken from the CIGAR format described
            in the Exonerate documentation.
            (http://cvsweb.sanger.ac.uk/cgi-bin/cvsweb.cgi/exonerate?cvsroot=Ensembl). ("THE GAP ATTRIBUTE")
         Parent, the Alias, Note, DBxref and Ontology_term attributes can have multiple values.
    
    """
"""
http://www.ensembl.org/info/website/upload/gff3.html
"""
"""
    https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md:
    seqid, source, type, start, end, score, phase, attributes: 
        ID, Name, Alias, Parent, Target, Gap, Derives_from, Note, Dbxref, Ontology_term, Is_circular
        (All attributes that begin with an uppercase letter are reserved for later use. 
        Attributes that begin with a lowercase letter can be used freely by applications.) 
"""