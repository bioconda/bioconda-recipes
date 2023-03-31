from metadata_csv import Adder
import os
from collections import OrderedDict
import click


class GeenuffLengthAdder(Adder):
    def __init__(self, mode, longest=False):
        self.mode = mode
        self.longest = longest

    @property
    def name(self):
        if self.longest:
            pfx = 'longest'
        else:
            pfx = 'all'
        return f'{pfx}_{self.mode}'

    def main_path(self, genome_path):
        file_name = f'{self.name}.tsv'
        return os.path.join(genome_path, 'meta_collection', 'geenuff', file_name)

    def add(self, genome_path, columns):
        with open(self.main_path(genome_path)) as f:
            n_lines = 0
            for line in f:
                parts = line.strip().split('\t')
                if parts[0] in self.key_matches:
                    columns[self.key_matches[parts[0]]].append(parts[1])
                    n_lines += 1
            if not n_lines:
                raise ValueError('No lines found at {}'.format(self.main_path(genome_path)))

    @property
    def key_matches(self):
        ret = OrderedDict([
            ('count', f'{self.name}__count'),
            ('longest', f'{self.name}__max'),
            ('shortest', f'{self.name}__min'),
            ('quantile_50%', f'{self.name}__median'),
            ('total', f'{self.name}__sum')])
        return ret


@click.command()
@click.option('--base-dir', help='data dir with usual proj structure, i.e. {Species}/meta_collection/geenuff folders', required=True)
@click.option('--defaults-on-err/--no-defaults-on-err', default=True,
              help='to fill in default values or to crash when s.t. is missing')
def main(base_dir, defaults_on_err):
    adders = []
    for longest in [True, False]:
        for mode in ["CDS", "exons", "intergenic", "introns", "mRNA", "pre-mRNA", "pre-UTR", "UTR"]:
            adders.append(GeenuffLengthAdder(mode=mode, longest=longest))

    columns = OrderedDict()
    columns['species'] = []
    for adder in adders:
        for key in adder.columns:
            columns[key] = []

    for genome in sorted(os.listdir(base_dir)):
        columns['species'].append(genome)
        genome_path = os.path.join(base_dir, genome)

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
    main()
