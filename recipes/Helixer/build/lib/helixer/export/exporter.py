import os
import time
import h5py
import numpy as np
import sqlite3
import datetime
import subprocess
import pkg_resources

import geenuff
import helixer
from geenuff.applications.exporter import GeenuffExportController
from geenuff.applications.importer import FastaImporter
from .numerify import CoordNumerifier


class HelixerExportControllerBase(object):

    def __init__(self, input_path, output_path, match_existing=False):
        self.input_path = input_path
        self.output_path = output_path
        self.match_existing = match_existing

    @staticmethod
    def calc_n_chunks(coord_len, chunk_size):
        """calculates the number of chunks resulting from a coord len and chunk size"""
        n_chunks = coord_len // chunk_size
        if coord_len % chunk_size:
            n_chunks += 1  # bc pad to size
        n_chunks *= 2  # for + & - strand
        return n_chunks

    @staticmethod
    def _create_dataset(h5_file, key, matrix, dtype, compression='gzip', create_empty=True):
        shape = list(matrix.shape)
        shuffle = len(shape) > 1
        if create_empty:
            shape[0] = 0  # create w/o size
        h5_file.create_dataset(key,
                               shape=shape,
                               maxshape=tuple([None] + shape[1:]),
                               chunks=tuple([1] + shape[1:]),
                               dtype=dtype,
                               compression=compression,
                               shuffle=shuffle)  # only for the compression

    def _create_or_expand_datasets(self, h5_group, flat_data, n_chunks, compression='gzip'):
        if h5_group not in self.h5 or len(self.h5[h5_group].keys()) == 0:
            for mat_info in flat_data:
                self._create_dataset(self.h5, h5_group + mat_info.key, mat_info.matrix, mat_info.dtype, compression)

        old_len = self.h5[h5_group + flat_data[0].key].shape[0]
        self.h5_coord_offset = old_len
        for mat_info in flat_data:
            self.h5[h5_group + mat_info.key].resize(old_len + n_chunks, axis=0)

    def _save_data(self, flat_data, h5_coords, n_chunks, first_round_for_coordinate, compression='gzip',
                   h5_group='/data/'):
        assert len(set(mat_info.matrix.shape[0] for mat_info in flat_data)) == 1, 'unequal data lengths'

        if first_round_for_coordinate:
            self._create_or_expand_datasets(h5_group, flat_data, n_chunks, compression)

        # h5_coords are relative for the coordinate/chromosome, so offset by previous length
        old_len = self.h5_coord_offset
        start = old_len + h5_coords[0]
        end = old_len + h5_coords[1]

        # writing to the h5 file
        for mat_info in flat_data:
            self.h5[h5_group + mat_info.key][start:end] = mat_info.matrix
        self.h5.flush()

    def _add_data_attrs(self):
        attrs = {
            'timestamp': str(datetime.datetime.now()),
            'input_path': self.input_path
        }
        # get GeenuFF and Helixer commit hashes
        pwd = os.getcwd()
        for module in [geenuff, helixer]:
            os.chdir(os.path.dirname(module.__file__))
            cmd = ['git', 'describe', '--always']  # show tag or hash if no tag available
            try:
                attrs[module.__name__ + '_commit'] = subprocess.check_output(cmd, stderr=subprocess.STDOUT).\
                    strip().decode()
            except subprocess.CalledProcessError:
                attrs[module.__name__ + '_commit'] = 'commit not found, version: {}'.format(
                    pkg_resources.require(module.__name__)[0].version
                )
                print('logged installed version in place of git commit for {}'.format(module.__name__))
        os.chdir(pwd)
        # insert attrs into .h5 file
        for key, value in attrs.items():
            self.h5.attrs[key] = value


class HelixerFastaToH5Controller(HelixerExportControllerBase):

    class CoordinateSurrogate(object):
        """Mimics some functionality of the Coordinate orm class, so we can go directly from FASTA to H5"""
        def __init__(self, seqid, seq):
            self.seqid = seqid
            self.sequence = seq
            self.length = len(seq)

        def __repr__(self):
            return f'Fasta only Coordinate (seqid: {self.seqid}, len: {self.length})'

    def export_fasta_to_h5(self, chunk_size, compression, multiprocess, species):
        fasta_importer = FastaImporter(None)
        fasta_seqs = fasta_importer.parse_fasta(self.input_path)
        self.h5 = h5py.File(self.output_path, 'w')

        for i, (seqid, seq) in enumerate(fasta_seqs):
            start_time = time.time()
            coord = HelixerFastaToH5Controller.CoordinateSurrogate(seqid, seq)
            n_chunks = HelixerExportControllerBase.calc_n_chunks(coord.length, chunk_size)
            data_gen = CoordNumerifier.numerify_only_fasta(coord, chunk_size, species, use_multiprocess=multiprocess)
            for j, strand_res in enumerate(data_gen):
                data, h5_coords = strand_res
                self._save_data(data, h5_coords=h5_coords, n_chunks=n_chunks,
                                first_round_for_coordinate=(j == 0), compression=compression)
            print(f'{i + 1} Numerified {coord} in {time.time() - start_time:.2f} secs', end='\n\n')
        self._add_data_attrs()
        self.h5.close()


class HelixerExportController(HelixerExportControllerBase):

    def __init__(self, input_path, output_path, match_existing=False, h5_group='/data/'):
        super().__init__(input_path, output_path, match_existing)
        self.h5_group = h5_group
        input_db_path = self.input_path
        self.h5_coord_offset = 0

        # check db
        conn = sqlite3.connect(input_db_path)
        c = conn.cursor()
        c.execute('''SELECT species from genome;''')
        genome_name_db = c.fetchall()
        conn.close()
        assert len(genome_name_db) == 1, f'{input_db_path} is not a valid db as it contains more than one genome'

        self.exporter = GeenuffExportController(input_db_path, longest=True)

        if match_existing:
            # confirm files exist
            assert os.path.exists(self.output_path), 'output_path not existing'
            self.h5 = h5py.File(output_path, 'a')
        else:
            self.h5 = h5py.File(output_path, 'w')
        print(f'Exporting all data to {output_path}')

    def _coord_info(self, coords_features):
        coord_info = {}
        for coord_id, coord_len in coords_features.keys():
            coord = self.exporter.get_coord_by_id(coord_id)
            seqid = coord.seqid.encode('ASCII')
            coord_info[seqid] = (coord_id, coord_len)
        return coord_info

    def _numerify_coord(self, coord, coord_features, chunk_size, one_hot, write_by, modes, multiprocess):
        """filtering and stats"""
        coord_data_gen = CoordNumerifier.numerify(coord, coord_features, chunk_size, one_hot,
                                                  write_by=write_by, mode=modes, use_multiprocess=multiprocess)
        # the following will all be used to calculated a percentage, which is yielded but ignored until the end
        n_chunks = n_bases = n_ig_bases = n_masked_bases = 0

        for coord_data, h5_coord in coord_data_gen:
            # easy access to matrices
            y = [cd.matrix for cd in coord_data if cd.key == 'y'][0]
            sample_weights = [cd.matrix for cd in coord_data if cd.key == 'sample_weights'][0]

            # count things, only works properly for one hot encodings
            n_chunks += y.shape[0]
            n_ig_bases += np.count_nonzero(y[:, :, 0] == 1)
            padded_bases = np.count_nonzero(np.all(y == 0, axis=2))
            n_bases += np.prod(y.shape[:2]) - padded_bases
            n_masked_bases += np.count_nonzero(sample_weights == 0) - padded_bases

            masked_bases_perc = n_masked_bases / n_bases * 100
            ig_bases_perc = n_ig_bases / n_bases * 100

            yield coord_data, coord, masked_bases_perc, ig_bases_perc, h5_coord

    def export(self, chunk_size, one_hot=True, longest_only=True, write_by=10_000_000_000,
               modes=('X', 'y', 'anno_meta', 'transitions'), compression='gzip', multiprocess=True):
        coords_features = self.exporter.genome_query(longest_only=longest_only)
        print(f'\n{len(coords_features)} coordinates chosen to numerify')
        if self.match_existing:
            # resort coordinates to match existing
            seqids = self.h5['data/seqids'][:]
            seqid_idxs = sorted(np.unique(seqids, return_index=True)[1])  # seqid info in the h5
            unique_seqids = seqids[seqid_idxs]

            coord_info = self._coord_info(coords_features)  # seqid info of the current data
            # the following assumes order preserving dict, which is the case since python 3.6
            coords_features = {coord_info[seqid]: coords_features[coord_info[seqid]] for seqid in unique_seqids}

        n_coords_done = 1
        n_writing_chunks = 0

        for (coord_id, coord_len), one_coord_features in coords_features.items():
            start_time = time.time()
            n_chunks = HelixerExportControllerBase.calc_n_chunks(coord_len, chunk_size)
            coord = self.exporter.get_coord_by_id(coord_id)
            numerify_outputs = self._numerify_coord(coord, one_coord_features, chunk_size, one_hot, write_by=write_by,
                                                    modes=modes, multiprocess=multiprocess)

            for i, (flat_data, coord, masked_bases_perc, ig_bases_perc, h5_coord) in enumerate(numerify_outputs):
                self._save_data(flat_data, h5_coords=h5_coord, n_chunks=n_chunks, first_round_for_coordinate=(i == 0),
                                compression=compression, h5_group=self.h5_group)
                n_writing_chunks += 1

            print(f'{n_coords_done}/{len(coords_features)} Numerified {coord} '
                  f"with {len(coord.features)} features in {flat_data[0].matrix.shape[0]} chunks, "
                  f'masked rate: {masked_bases_perc:.2f}%, ig rate: {ig_bases_perc:.2f}%, '
                  f'({time.time() - start_time:.2f} secs)', end='\n\n')
            n_coords_done += 1
        self._add_data_attrs()
        self.h5.close()
        print('Export from geenuff db to h5 file(s) with numeric matrices finished successfully.')
        return n_writing_chunks  # for testing only atm
