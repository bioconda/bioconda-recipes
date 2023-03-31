#! /usr/bin/env python3
from helixer.core.scripts import ExportParameterParser
from helixer.export.exporter import HelixerExportController


def main(args):
    if args.modes == 'all':
        modes = ('X', 'y', 'anno_meta', 'transitions')
    else:
        modes = tuple(args.modes.split(','))

    if args.add_additional:
        match_existing = True
        h5_group = '/alternative/' + args.add_additional + '/'
    else:
        match_existing = False
        h5_group = '/data/'

    write_by = round(args.write_by / args.subsequence_length) * args.subsequence_length
    controller = HelixerExportController(args.input_db_path, args.h5_output_path, match_existing=match_existing,
                                         h5_group=h5_group)
    controller.export(chunk_size=args.subsequence_length, write_by=write_by, modes=modes, compression=args.compression,
                      multiprocess=not args.no_multiprocess)


if __name__ == '__main__':
    pp = ExportParameterParser(config_file_path='config/geenuff2h5_config.yaml')
    pp.io_group.add_argument('--input-db-path', type=str, required=True,
                            help='Path to the GeenuFF SQLite input database (has to contain only one genome).')
    pp.io_group.add_argument('--add-additional', type=str,
                            help='Outputs the datasets under alternatives/{add-additional}/ (and checks sort order against '
                                 'existing "data" datasets). Use to add e.g. additional annotations from Augustus.')
    pp.data_group.add_argument('--subsequence-length', type=int,
                              help='Length of the subsequences that the model will use at once. (Default is 21384)')
    pp.data_group.add_argument('--modes', type=str,
                              help='Either "all" (default), or a comma separated list with desired members of the following '
                                   '{X, y, anno_meta, transitions} that should be exported. This can be useful, for '
                                   'instance when skipping transitions (to reduce size/mem) or skipping X because '
                                   'you are adding an additional annotation set to an existing file.')
    pp.data_group.add_argument('--write-by', type=int,
                              help='Write in super-chunks with this many base pairs, which will be rounded to be '
                                   'divisible by subsequence-length. (Default is 21_384_000_000).')

    # need to add any default values like this
    pp.defaults['add_additional'] = ''
    pp.defaults['subsequence_length'] = 21384
    pp.defaults['modes'] = 'all'
    pp.defaults['write_by'] = 21_384_000_000

    args = pp.get_args()
    main(args)
