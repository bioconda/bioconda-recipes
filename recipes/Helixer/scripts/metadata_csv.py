#! /usr/bin/env python3
import os
import argparse
from glob import glob
import sys
from collections import OrderedDict


class Adder:

    @property
    def main_path(self, genome_path):
        raise NotImplementedError

    @property
    def key_matches(self):
        return None

    @property
    def _columns_only(self):
        raise NotImplementedError

    @property
    def default(self):
        return 'NA'

    @property
    def columns(self):
        if self.key_matches is not None:
            return self.key_matches.values()
        else:
            return self._columns_only

    def add(self, genome_path, columns):
        raise NotImplementedError

    def add_safe(self, genome_path, columns, defaults_on_err=False):
        try:
            self.add(genome_path, columns)
        except Exception as e:
            print('\n### trouble parsing {}'.format(self.main_path(genome_path)), file=sys.stderr)
            if defaults_on_err:
                print('### error was: ({})'.format(e), file=sys.stderr)
                print('### ignoring and inserting defaults\n', file=sys.stderr)
                for key in self.columns:
                    columns[key].append(self.default)
            else:
                print('### to ignore the following error and use defaults set --use_defaults_on_err\n',
                      file=sys.stderr)
                raise e


class GffAdder(Adder):
    @property
    def _columns_only(self):
        return ['CDS', 'exon', 'five_prime_UTR', 'three_prime_UTR', 'gene', 'mRNA']

    def main_path(self, genome_path):
        return os.path.join(genome_path, 'meta_collection', 'gff_features', 'counts.txt')

    def add(self, genome_path, columns):
        # some values may be missing so setup dict with default values
        gff_values = {}
        for key in self._columns_only:
            gff_values[key] = '0'

        with open(self.main_path(genome_path)) as f:
            for line in f:
                parts = line.strip().split(' ')
                if parts[1] in self._columns_only:
                    gff_values[parts[1]] = parts[0]
        for gff_type, count in gff_values.items():
            columns[gff_type].append(count)


class QuastAdder(Adder):
    @property
    def key_matches(self):
        ret = OrderedDict([
            ('# contigs (>= 0 bp)', 'contigs'),
            ('# contigs (>= 1000 bp)', 'contigs_gt_1k'),
            ('# contigs (>= 5000 bp)', 'contigs_gt_5k'),
            ('# contigs (>= 10000 bp)', 'contigs_gt_10k'),
            ('# contigs (>= 25000 bp)', 'contigs_gt_25k'),
            ('# contigs (>= 50000 bp)', 'contigs_gt_50k'),
            ('Total length (>= 0 bp)', 'total_len'),
            ('Total length (>= 1000 bp)', 'total_len_gt_1k'),
            ('Total length (>= 5000 bp)', 'total_len_gt_5k'),
            ('Total length (>= 10000 bp)', 'total_len_gt_10k'),
            ('Total length (>= 25000 bp)', 'total_len_gt_25k'),
            ('Total length (>= 50000 bp)', 'total_len_gt_50k'),
            ('Largest contig', 'largest_contig'),
            ('GC (%)', 'gc_content'),
            ('N50', 'N50'),
            ('N75', 'N75'),
            ('L50', 'L50'),
            ('L75', 'L75'),
        ])
        return ret

    def main_path(self, genome_path):
        return os.path.join(genome_path, 'meta_collection', 'quast', 'geno', 'report.tsv')

    def add(self, genome_path, columns):
        with open(self.main_path(genome_path)) as f:
            for line in f:
                parts = line.strip().split('\t')
                if parts[0] in self.key_matches:
                    columns[self.key_matches[parts[0]]].append(parts[1])


class BuscoAdder(Adder):

    BASE_KEY_MATCHES = OrderedDict([
        ('Complete BUSCOs (C)', 'busco_C'),
        ('Complete and single-copy BUSCOs (S)', 'busco_S'),
        ('Complete and duplicated BUSCOs (D)', 'busco_D'),
        ('Fragmented BUSCOs (F)', 'busco_F'),
        ('Missing BUSCOs (M)', 'busco_M'),
    ])

    def __init__(self, scale, busco_type):
        self.scale = scale
        self.busco_type = busco_type

    @property
    def key_matches(self):
        out = OrderedDict()
        for key, val in BuscoAdder.BASE_KEY_MATCHES.items():
            out[key] = '{}_{}'.format(val, self.busco_type)
        return out

    def main_path(self, genome_path):
        path = os.path.join(genome_path, 'meta_collection', 'busco', self.busco_type)
        return os.path.join(path, 'short_summary*.txt')

    def add(self, genome_path, columns):
        with open(glob(self.main_path(genome_path))[0]) as f:
            for line in f:
                parts = line.strip().split('\t')
                if len(parts) == 1 and parts[0].startswith('C:'):
                    total_buscos = int(parts[0].split(':')[-1])
                elif len(parts) > 1 and parts[1] in self.key_matches:
                    if self.scale:
                        value = '{:.4f}'.format(int(parts[0]) / total_buscos)
                    else:
                        value = parts[0]
                    columns[self.key_matches[parts[1]]].append(value)


class KmerAdder(Adder):
    def __init__(self, scale, length):
        self.scale = scale
        self.kmer_length = length

    def main_path(self, genome_path):
        file_name = 'k' + self.kmer_length + 'mer_counts.tsv'
        return os.path.join(genome_path, 'meta_collection', 'jellyfish', file_name)

    def add(self, genome_path, columns):
        # jellyfish
        with open(self.main_path(genome_path)) as f:
            for line in f:
                parts = line.strip().split('\t')
                if self.scale:
                    value = '{:.4f}'.format(int(parts[0]) / float(columns['total_len'][-1]))
                else:
                    value = parts[0]
                columns[parts[1]].append(value)


class OnemerAdder(KmerAdder):
    def __init__(self, scale):
        super().__init__(scale, '1')

    @property
    def _columns_only(self):
        return ['A', 'C', 'N']


class TwomerAdder(KmerAdder):
    def __init__(self, scale):
        super().__init__(scale, '2')

    @property
    def _columns_only(self):
        return ['AA', 'AC', 'AG', 'AT', 'CA', 'CC', 'CG', 'GA', 'GC', 'TA']


def main(base_path, scale, defaults_on_err):
    adders = [GffAdder(),
              QuastAdder(),
              BuscoAdder(scale, 'geno'),
              BuscoAdder(scale, 'prot'),
              BuscoAdder(scale, 'tran'),
              OnemerAdder(scale),
              TwomerAdder(scale),
              ]

    columns = OrderedDict()
    columns['species'] = []
    for adder in adders:
        for key in adder.columns:
            columns[key] = []

    for genome in sorted(os.listdir(base_path)):
        columns['species'].append(genome)
        genome_path = os.path.join(base_path, genome)

        for adder in adders:
            adder.add_safe(genome_path, columns, defaults_on_err=defaults_on_err)

    # checks
    species_len = len(columns['species'])
    for key, value_list in columns.items():
        assert len(value_list) == species_len, 'len({}) == {} != {} @ {}'.format(value_list, len(value_list),
                                                                                 species_len, key)

    # output csv
    delimiter = ','
    print(delimiter.join(list(columns.keys())))
    for i in range(len(columns['species'])):
        print(delimiter.join([columns[key][i] for key in columns.keys()]))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--scale', action='store_true', help='Whether to scale the kmer and busco columns')
    parser.add_argument('--basepath', default='/mnt/data/ali/share/phytozome_organized/ready/train/',
                        help="path to the folder containing organized species folders")
    parser.add_argument('--use_defaults_on_err', action='store_true',
                        help="set this to ignore any and all errors raised during parsing and use default values")
    args = parser.parse_args()

    main(args.basepath, args.scale, args.use_defaults_on_err)
