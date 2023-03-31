import os
from shutil import copy
from sklearn.metrics import precision_recall_fscore_support as f1_scores
from sklearn.metrics import accuracy_score
import numpy as np
import pytest
import h5py

import geenuff
from geenuff.tests.test_geenuff import mk_memory_session
from geenuff.applications.importer import ImportController
from geenuff.base.orm import SuperLocus, Genome, Coordinate
from geenuff.base.helpers import reverse_complement
from geenuff.base import types

from ..core.controller import HelixerController
from ..core import helpers
from ..core import overlap
from ..export import numerify
from ..export.numerify import SequenceNumerifier, AnnotationNumerifier, Stepper, AMBIGUITY_DECODE
from ..export.exporter import HelixerExportController, HelixerFastaToH5Controller
from ..prediction.Metrics import ConfusionMatrix, ConfusionMatrixGenic
from helixer.prediction.LSTMModel import LSTMSequence
from ..evaluation import rnaseq

TMP_DB = 'testdata/tmp/dummy.sqlite3'
DUMMYLOCI_DB = 'testdata/dummyloci/dummyloci.sqlite3'
H5_OUT_FOLDER = 'testdata/numerify_test_out/'
H5_OUT_FILE = H5_OUT_FOLDER + 'test_data.h5'
FASTA_OUT_FILE = H5_OUT_FOLDER + 'fasta_test_data.h5'
EVAL_H5 = 'testdata/tmp.h5'


### preparation and breakdown ###
@pytest.fixture(scope="session", autouse=True)
def setup_dummy_db(request):
    if not os.getcwd().endswith('Helixer/helixer'):
        pytest.exit('Tests need to be run from Helixer/helixer directory')

    if os.path.exists(DUMMYLOCI_DB):
        os.remove(DUMMYLOCI_DB)

    os.makedirs(os.path.dirname(TMP_DB), exist_ok=True)
    os.makedirs(os.path.dirname(DUMMYLOCI_DB), exist_ok=True)

    # make sure we have the same test data that Geenuff has
    geenuff_test_folder = os.path.dirname(geenuff.__file__) + '/testdata/'
    files = ['dummyloci.fa', 'dummyloci.gff', 'basic_sequences.fa']
    for f in files:
        copy(geenuff_test_folder + f, 'testdata/')

    # setup dummyloci, import into a Geenuff database
    controller = ImportController(database_path='sqlite:///' + DUMMYLOCI_DB, config={})
    controller.add_genome('testdata/dummyloci.fa', 'testdata/dummyloci.gff',
                          genome_args={"species": "dummy"})

    # make tmp folder
    if not os.path.exists(H5_OUT_FOLDER):
        os.mkdir(H5_OUT_FOLDER)

    # stuff after yield is going to be executed after all tests are run
    yield None

    # clean up tmp files
    for p in [TMP_DB, DUMMYLOCI_DB] + [H5_OUT_FOLDER + f for f in os.listdir(H5_OUT_FOLDER)]:
        if os.path.exists(p):
            os.remove(p)
    os.rmdir(H5_OUT_FOLDER)


@pytest.fixture(scope="session", autouse=True)
def setup_dummy_evaluation_h5(request):
    start_ends = [[0, 20000],  # increasing 0
                  [20000, 40000],  # increasing 0
                  [60000, 80000],  # increasing 1
                  [100000, 120000],  # increasing 2
                  [120000, 133333],  # increasing 3 (non contig, bc special edge handling)
                  [133333, 120000],  # decreasing 0 (")
                  [120000, 100000],  # decreasing 1
                  [100000, 80000],  # decreasing 1
                  [60000, 40000],  # decreasing 2
                  [20000, 0]]  # decreasing 3
    seqids = [b'chr1'] * len(start_ends)
    h5path = EVAL_H5

    h5 = h5py.File(h5path, 'a')
    h5.create_group('data')
    h5.create_dataset('/data/start_ends', data=start_ends, dtype='int64', compression='lzf')
    h5.create_dataset('/data/seqids', data=seqids, dtype='S50', compression='lzf')

    h5.create_group('evaluation')
    h5.create_dataset('evaluation/coverage', shape=[10, 20000], dtype='int', fillvalue=-1, compression='lzf')
    h5.close()

    yield None  # all tests are run

    os.remove(h5path)


### helper functions ###
def mk_controllers(source_db, helixer_db=TMP_DB, h5_out=H5_OUT_FILE):
    for p in [helixer_db, h5_out]:
        if os.path.exists(p):
            os.remove(p)

    mer_controller = HelixerController(source_db, helixer_db, '', '')
    export_controller = HelixerExportController(helixer_db, h5_out)
    return mer_controller, export_controller


def memory_import_fasta(fasta_path):
    controller = ImportController(database_path='sqlite:///:memory:', config={})
    controller.add_sequences(fasta_path)
    coords = controller.session.query(Coordinate).order_by(Coordinate.id).all()
    return controller, coords


def setup_dummyloci():
    _, export_controller = mk_controllers(DUMMYLOCI_DB)
    session = export_controller.exporter.session
    coordinate = session.query(Coordinate).first()
    return session, export_controller, coordinate


def setup_simpler_numerifier():
    sess = mk_memory_session()
    genome = Genome()
    coord = Coordinate(genome=genome, sequence='A' * 100, length=100, seqid='a')
    sl = SuperLocus()
    transcript = geenuff.orm.Transcript(super_locus=sl)
    piece = geenuff.orm.TranscriptPiece(transcript=transcript, position=0)
    transcript_feature = geenuff.orm.Feature(start=40,
                                             end=9,
                                             is_plus_strand=False,
                                             type=geenuff.types.GEENUFF_TRANSCRIPT,
                                             start_is_biological_start=True,
                                             end_is_biological_end=True,
                                             coordinate=coord)
    piece.features = [transcript_feature]

    sess.add_all([genome, coord, sl, transcript, piece, transcript_feature])
    sess.commit()
    return sess, coord


### db import from GeenuFF ###
def test_copy_n_import():
    _, controller = mk_controllers(source_db=DUMMYLOCI_DB)
    session = controller.exporter.session
    sl = session.query(SuperLocus).filter(SuperLocus.given_name == 'gene0').one()
    assert len(sl.transcripts) == 3
    assert len(sl.proteins) == 3
    all_features = []
    for transcript in sl.transcripts:
        assert len(transcript.transcript_pieces) == 1
        piece = transcript.transcript_pieces[0]
        for feature in piece.features:
            if feature.type.value not in types.geenuff_error_type_values:
                all_features.append(feature)
        print('{}: {}'.format(transcript.given_name, [x.type.value for x in piece.features]))
    for protein in sl.proteins:
        print('{}: {}'.format(protein.given_name, [x.type.value for x in protein.features]))

    # if I ever get to collapsing redundant features this will change
    assert len(all_features) == 9


#### numerify ####
def test_stepper():
    # evenly divided
    s = Stepper(50, 10)
    strt_ends = list(s.step_to_end())
    assert len(strt_ends) == 5
    assert strt_ends[0] == (0, 10)
    assert strt_ends[-1] == (40, 50)
    # a bit short
    s = Stepper(49, 10)
    strt_ends = list(s.step_to_end())
    assert len(strt_ends) == 5
    assert strt_ends[-1] == (40, 49)
    # a bit long
    s = Stepper(52, 10)
    strt_ends = list(s.step_to_end())
    assert len(strt_ends) == 6
    assert strt_ends[-1] == (50, 52)
    # very short
    s = Stepper(9, 10)
    strt_ends = list(s.step_to_end())
    assert len(strt_ends) == 1
    assert strt_ends[-1] == (0, 9)


def test_short_sequence_numerify():
    _, coords = memory_import_fasta('testdata/basic_sequences.fa')
    numerifier = SequenceNumerifier(coord=coords[3], max_len=100)
    matrix = numerifier.coord_to_matrices()['plus'][0]
    # ATATATAT
    x = [0., 1, 0, 0, 0., 0, 1, 0]
    expect = np.array(x * 4).reshape((-1, 4))
    assert np.array_equal(expect, matrix)

    # on the minus strand
    numerifier = SequenceNumerifier(coord=coords[3], max_len=100)
    matrix = numerifier.coord_to_matrices()['plus'][0]

    seq_comp = reverse_complement(coords[3].sequence)
    expect = [numerify.AMBIGUITY_DECODE[bp] for bp in seq_comp]
    expect = np.vstack(expect)
    assert np.array_equal(expect, matrix)


def test_base_level_annotation_numerify():
    _, _, coord = setup_dummyloci()
    numerifier = AnnotationNumerifier(coord=coord,
                                      features=coord.features,
                                      max_len=5000,
                                      one_hot=False)
    nums = numerifier.coord_to_matrices()[0]["plus"][0][:405]
    expect = np.zeros([405, 3], dtype=np.float32)
    expect[0:400, 0] = 1.  # set genic/in raw transcript
    expect[10:301, 1] = 1.  # set in transcript
    expect[21:110, 2] = 1.  # both introns
    expect[120:200, 2] = 1.
    assert np.array_equal(nums, expect)


def test_sequence_slicing():
    _, coords = memory_import_fasta('testdata/basic_sequences.fa')
    seq_numerifier = SequenceNumerifier(coord=coords[0], max_len=50)
    num_mats = seq_numerifier.coord_to_matrices()
    num_list = num_mats["plus"] + num_mats["minus"]
    print([x.shape for x in num_list])
    # [(50, 4), (50, 4), (50, 4), (50, 4), (50, 4), (50, 4), (50, 4), (50, 4), (5, 4)]
    assert len(num_list) == 9 * 2  # both strands

    for i in range(8):
        assert np.array_equal(num_list[i], np.full([50, 4], 0.25, dtype=np.float32))
    assert np.array_equal(num_list[8], np.full([5, 4], 0.25, dtype=np.float32))


def test_coherent_slicing():
    """Tests for coherent output when slicing the 405 bp long dummyloci.
    The correct divisions are already tested in the Stepper test.
    The array format of the individual matrices are tested in
    test_short_sequence_numerify().
    """
    _, _, coord = setup_dummyloci()
    seq_numerifier = SequenceNumerifier(coord=coord,
                                        max_len=100)
    anno_numerifier = AnnotationNumerifier(coord=coord,
                                           features=coord.features,
                                           max_len=100,
                                           one_hot=False)

    seq_mats = seq_numerifier.coord_to_matrices()
    # appending +&- is historical / avoiding re-writing the test...
    seq_slices = seq_mats['plus'] + seq_mats['minus']

    anno_mats = anno_numerifier.coord_to_matrices()
    anno_mats = [x["plus"] + x['minus'] for x in anno_mats]
    anno_slices, anno_error_masks, gene_lengths, phases, transitions = anno_mats
    assert (len(seq_slices) == len(anno_slices) == len(gene_lengths) == len(transitions) ==
            len(phases) == len(anno_error_masks) == 19 * 2)

    for s, a, ae in zip(seq_slices, anno_slices, anno_error_masks):
        assert s.shape[0] == a.shape[0] == ae.shape[0]

    # testing sequence error masks
    expect = np.ones((1801 * 2,), dtype=np.int8)

    # annotation error mask of test case 1 should reflect faulty exon/CDS ranges
    expect[:110] = 0
    expect[120:499] = 0  # error from test case 1
    # expect[499:1099] = 0  # error from test case 2, which we do not mark atm
    # test equality for correct error ranges of first two test cases + some correct bases
    assert np.array_equal(expect[:1150], np.concatenate(anno_error_masks)[:1150])


def test_minus_strand_numerify():
    # setup a very basic -strand locus
    _, coord = setup_simpler_numerifier()
    numerifier = AnnotationNumerifier(coord=coord,
                                      features=coord.features,
                                      max_len=1000,
                                      one_hot=False)
    nums = numerifier.coord_to_matrices()[0]
    # first, we should make sure the opposite strand is unmarked when empty
    expect = np.zeros([100, 3], dtype=np.float32)
    assert np.array_equal(nums["plus"][0], expect)

    # and now that we get the expect range on the minus strand,
    # keeping in mind the 40 is inclusive, and the 9, not
    expect[10:41, 0] = 1.
    expect = np.flip(expect, axis=0)
    assert np.array_equal(nums["minus"][0], expect)

    # with cutting
    numerifier = AnnotationNumerifier(coord=coord,
                                      features=coord.features,
                                      max_len=50,
                                      one_hot=False)
    nums = numerifier.coord_to_matrices()[0]

    expect = np.zeros([100, 3], dtype=np.float32)
    expect[10:41, 0] = 1.

    assert np.array_equal(nums['minus'][0], np.flip(expect[50:100], axis=0))
    assert np.array_equal(nums['minus'][1], np.flip(expect[0:50], axis=0))


def test_coord_numerifier_and_h5_gen_plus_strand():
    _, controller, _ = setup_dummyloci()
    # dump the whole db in chunks into a .h5 file
    controller.export(chunk_size=400, one_hot=False, longest_only=False)

    f = h5py.File(H5_OUT_FILE, 'r')
    x = f['/data/X'][:]
    y = f['/data/y'][:]
    sample_weights = f['/data/sample_weights'][:]

    # five chunks for each the two annotated coordinates and one for the unannotated coord #3
    assert len(x) == len(y) == len(sample_weights) == 22

    # prep seq
    x_expect = np.full((405, 4), 0.25)
    # set start codon
    x_expect[10] = numerify.AMBIGUITY_DECODE['A']
    x_expect[11] = numerify.AMBIGUITY_DECODE['T']
    x_expect[12] = numerify.AMBIGUITY_DECODE['G']
    # stop codons
    x_expect[117] = numerify.AMBIGUITY_DECODE['T']
    x_expect[118] = numerify.AMBIGUITY_DECODE['A']
    x_expect[119] = numerify.AMBIGUITY_DECODE['G']
    x_expect[298] = numerify.AMBIGUITY_DECODE['T']
    x_expect[299] = numerify.AMBIGUITY_DECODE['G']
    x_expect[300] = numerify.AMBIGUITY_DECODE['A']
    assert np.array_equal(x[0], x_expect[:400])
    assert np.array_equal(x[1][:5], x_expect[400:])

    # prep anno
    y_expect = np.zeros((405, 3), dtype=np.float16)
    y_expect[0:400, 0] = 1.  # set genic/in raw transcript
    y_expect[10:301, 1] = 1.  # set in transcript
    y_expect[21:110, 2] = 1.  # both introns
    y_expect[120:200, 2] = 1.
    assert np.array_equal(y[0], y_expect[:400])
    assert np.array_equal(y[1][:5], y_expect[400:])

    # prep anno mask
    sample_weight_expect = np.ones((405,), dtype=np.int8)
    sample_weight_expect[:110] = 0
    sample_weight_expect[120:] = 0
    assert np.array_equal(sample_weights[0], sample_weight_expect[:400])
    assert np.array_equal(sample_weights[1][:5], sample_weight_expect[400:])


def test_coord_numerifier_and_h5_gen_minus_strand():
    """Tests numerification of test case 8 on coordinate 2"""
    _, controller, _ = setup_dummyloci()
    # dump the whole db in chunks into a .h5 file
    controller.export(chunk_size=200, one_hot=False, longest_only=False)

    f = h5py.File(H5_OUT_FILE, 'r')
    x = f['/data/X'][:]
    y = f['/data/y'][:]
    sample_weights = f['/data/sample_weights'][:]

    assert len(x) == len(y) == len(sample_weights) == 42

    # the x/y selected below should be for the 2nd coord and the minus strand
    # all the sequences are 0-padded
    second_coord_minus = slice(29, 34)
    x = x[second_coord_minus]
    y = y[second_coord_minus]
    sample_weights = sample_weights[second_coord_minus]

    x_expect = np.full((955, 4), 0.25)
    # start codon
    x_expect[929] = np.flip(AMBIGUITY_DECODE['T'])
    x_expect[928] = np.flip(AMBIGUITY_DECODE['A'])
    x_expect[927] = np.flip(AMBIGUITY_DECODE['C'])
    # stop codon of second transcript
    x_expect[902] = np.flip(AMBIGUITY_DECODE['A'])
    x_expect[901] = np.flip(AMBIGUITY_DECODE['T'])
    x_expect[900] = np.flip(AMBIGUITY_DECODE['C'])
    # stop codon of first transcript
    x_expect[776] = np.flip(AMBIGUITY_DECODE['A'])
    x_expect[775] = np.flip(AMBIGUITY_DECODE['T'])
    x_expect[774] = np.flip(AMBIGUITY_DECODE['C'])
    # flip as the sequence is read 5p to 3p
    x_expect = np.flip(x_expect, axis=0)
    # insert 0-padding
    x_expect = np.insert(x_expect, 155, np.zeros((45, 4)), axis=0)
    assert np.array_equal(x[0], x_expect[:200])
    assert np.array_equal(x[1][:50], x_expect[200:250])

    y_expect = np.zeros((955, 3), dtype=np.float16)
    y_expect[749:950, 0] = 1.  # genic region
    y_expect[774:930, 1] = 1.  # transcript (2 overlapping ones)
    y_expect[850:919, 2] = 1.  # intron first transcript
    y_expect[800:879, 2] = 1.  # intron second transcript
    y_expect = np.flip(y_expect, axis=0)
    y_expect = np.insert(y_expect, 155, np.zeros((45, 3)), axis=0)
    assert np.array_equal(y[0], y_expect[:200])
    assert np.array_equal(y[1][:50], y_expect[200:250])

    sample_weight_expect = np.ones((955,), dtype=np.int8)
    sample_weight_expect[925:] = 0
    sample_weight_expect[749:850] = 0
    sample_weight_expect = np.flip(sample_weight_expect)
    sample_weight_expect = np.insert(sample_weight_expect, 155, np.zeros((45,)), axis=0)
    assert np.array_equal(sample_weights[0], sample_weight_expect[:200])
    assert np.array_equal(sample_weights[1][:50], sample_weight_expect[200:250])


def test_numerify_with_end_neg1():
    def check_one(coord, is_plus_strand, expect, maskexpect):
        numerifier = AnnotationNumerifier(coord=coord,
                                          features=coord.features,
                                          max_len=1000,
                                          one_hot=False)

        if is_plus_strand:
            nums, masks, _, _, _ = [x["plus"][0] for x in numerifier.coord_to_matrices()]
        else:
            nums, masks, _, _, _ = [x["minus"][0] for x in numerifier.coord_to_matrices()]

        if not np.array_equal(nums, expect):
            print(nums)
            for i in range(nums.shape[0]):
                if not np.all(nums[i] == expect[i]):
                    print("nums[i] != expect[i]: {} != {}, @ {}".format(nums[i], expect[i], i))
            assert False, "label arrays not equal, see above"
        if not np.array_equal(masks, maskexpect):
            for i in range(len(masks)):
                if masks[i] != maskexpect[i]:
                    print("masks[i] != maskexpect[i]: {} != {}, @ {}".format(masks[i], maskexpect[i], i))
            assert False, "mask arrays not equal, see above"

    def expect0():
        return np.zeros([1000, 3], dtype=np.float32)

    def masks1():
        return np.ones((1000,), dtype=int)

    controller = ImportController(database_path='sqlite:///:memory:', config={})
    controller.add_genome('testdata/edges.fa', 'testdata/edges.gff',
                          genome_args={"species": "edges"})
    # test case: plus strand, start, features
    # + (each char represents ~ 50bp)
    # 1111 0000 0000 0000 0000 0000
    # 0110 0000 0000 0000 0000 0000
    # 0000 0000 0000 0000 0000 0000
    # err
    # 1111 1111 1111 1111 1111 1111
    coord = controller.session.query(Coordinate).filter(Coordinate.id == 1).first()
    expect = expect0()
    expect[0:200, 0] = 1.  # transcribed
    expect[50:149, 1] = 1.

    maskexpect = masks1()
    check_one(coord, True, expect, maskexpect)
    # - strand, as above, but expect all 0s no masking
    expect = expect0()
    check_one(coord, False, expect, maskexpect)

    # test case: plus strand, start, errors
    # + (each char represents ~ 50bp)
    # 0111 0000 0000 0000 0000 0000
    # 0110 0000 0000 0000 0000 0000
    # 0000 0000 0000 0000 0000 0000
    # err
    # 0111 1111 1111 1111 1111 1111
    coord = controller.session.query(Coordinate).filter(Coordinate.id == 2).first()
    expect = expect0()
    expect[50:200, 0] = 1.
    expect[50:149, 1] = 1.
    maskexpect = masks1()
    maskexpect[0:50] = 0
    check_one(coord, True, expect, maskexpect)
    # - strand
    expect = expect0()
    maskexpect = masks1()
    check_one(coord, False, expect, maskexpect)

    # test case: minus strand, end, features
    # -
    # 0000 0000 0000 0000 0000 1111
    # 0000 0000 0000 0000 0000 0110
    # 0000 0000 0000 0000 0000 0000
    # err
    # 1111 1111 1111 1111 1111 1111
    coord = controller.session.query(Coordinate).filter(Coordinate.id == 3).first()
    expect = expect0()
    expect[0:200, 0] = 1.  # transcribed
    expect[50:149, 1] = 1.
    expect = np.flip(expect, axis=0)

    maskexpect = masks1()
    check_one(coord, False, expect, maskexpect)
    # + strand, as above, but expect all 0s no masking
    expect = expect0()
    check_one(coord, True, expect, maskexpect)

    # test case: minus strand, end, errors
    # -
    # 0000 0000 0000 0000 0000 1110
    # 0000 0000 0000 0000 0000 0110
    # 0000 0000 0000 0000 0000 0000
    # err
    # 1111 1111 1111 1111 1111 1110
    coord = controller.session.query(Coordinate).filter(Coordinate.id == 4).first()
    expect = expect0()
    expect[50:200, 0] = 1.  # transcribed
    expect[50:149, 1] = 1.
    expect = np.flip(expect, axis=0)

    maskexpect = masks1()
    maskexpect[0:50] = 0
    maskexpect = np.flip(maskexpect, axis=0)
    check_one(coord, False, expect, maskexpect)
    # + strand, as above, but expect all 0s no masking
    expect = expect0()
    maskexpect = masks1()
    check_one(coord, True, expect, maskexpect)

    # test case: plus strand, end, features
    # +
    # 0000 0000 0000 0000 0000 1111
    # 0000 0000 0000 0000 0000 0110
    # 0000 0000 0000 0000 0000 0000
    # err
    # 1111 1111 1111 1111 1111 1111
    coord = controller.session.query(Coordinate).filter(Coordinate.id == 5).first()
    expect = expect0()
    expect[799:1000, 0] = 1.  # transcribed
    expect[851:950, 1] = 1.
    maskexpect = masks1()
    check_one(coord, True, expect, maskexpect)
    # - strand, as above, but expect all 0s no masking
    expect = expect0()
    maskexpect = masks1()
    check_one(coord, False, expect, maskexpect)

    # test case: plus strand, end, errors
    # +
    # 0000 0000 0000 0000 0000 1110
    # 0000 0000 0000 0000 0000 0110
    # 0000 0000 0000 0000 0000 0000
    # err
    # 1111 1111 1111 1111 1111 1110
    coord = controller.session.query(Coordinate).filter(Coordinate.id == 6).first()
    expect = expect0()
    expect[799:950, 0] = 1.  # transcribed
    expect[851:950, 1] = 1.
    maskexpect = masks1()
    maskexpect[950:1000] = 0
    check_one(coord, True, expect, maskexpect)
    # - strand, as above, but expect all 0s no masking
    expect = expect0()
    maskexpect = masks1()
    check_one(coord, False, expect, maskexpect)

    # test case: minus strand, start, features
    # -
    # 1111 0000 0000 0000 0000 0000
    # 0110 0000 0000 0000 0000 0000
    # 0000 0000 0000 0000 0000 0000
    # err
    # 1111 1111 1111 1111 1111 1111
    coord = controller.session.query(Coordinate).filter(Coordinate.id == 7).first()
    expect = expect0()
    expect[799:1000, 0] = 1.  # transcribed
    expect[851:950, 1] = 1.
    expect = np.flip(expect, axis=0)
    maskexpect = masks1()
    check_one(coord, False, expect, maskexpect)
    # + strand, as above, but expect all 0s no masking
    expect = expect0()
    maskexpect = masks1()
    check_one(coord, True, expect, maskexpect)

    # test case: minus strand, start, errors
    # -
    # 0111 0000 0000 0000 0000 0000
    # 0110 0000 0000 0000 0000 0000
    # 0000 0000 0000 0000 0000 0000
    # err
    # 0111 1111 1111 1111 1111 1111
    coord = controller.session.query(Coordinate).filter(Coordinate.id == 8).first()
    expect = expect0()
    expect[799:950, 0] = 1.  # transcribed
    expect[851:950, 1] = 1.
    expect = np.flip(expect, axis=0)
    maskexpect = masks1()
    maskexpect[950:1000] = 0
    maskexpect = np.flip(maskexpect, axis=0)
    check_one(coord, False, expect, maskexpect)
    # + strand, as above, but expect all 0s no masking
    expect = expect0()
    maskexpect = masks1()
    check_one(coord, True, expect, maskexpect)


def test_one_hot_encodings():
    classes_multi = [
        [0, 0, 0],
        [1, 0, 0],
        [1, 1, 0],
        [1, 1, 1],
    ]
    classes_4 = [
        [1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 1],
    ]

    # make normal encoding (multi class)
    _, _, coord = setup_dummyloci()
    numerifier = AnnotationNumerifier(coord=coord,
                                      features=coord.features,
                                      max_len=5000,
                                      one_hot=False)

    y_multi = numerifier.coord_to_matrices()[0]["plus"][0]
    # count classes
    uniques_multi = np.unique(y_multi, return_counts=True, axis=0)

    # make one hot encoding
    numerifier = AnnotationNumerifier(coord=coord,
                                      features=coord.features,
                                      max_len=5000,
                                      one_hot=True)
    y_one_hot_4 = numerifier.coord_to_matrices()[0]["plus"][0]
    uniques_4 = np.unique(y_one_hot_4, return_counts=True, axis=0)
    # this loop has to be changed when using accounting for non-coding introns as well
    for i in range(len(classes_multi)):
        idx = (uniques_4[0] == classes_4[i]).all(axis=1).nonzero()[0][0]
        assert uniques_multi[1][i] == uniques_4[1][idx]

    # test if they are one-hot at all
    assert np.all(np.count_nonzero(y_one_hot_4, axis=1) == 1)


def test_confusion_matrix():
    # 10 bases Intergenic
    # 8 bases UTR
    # 11 bases exon
    # 2 bases intron
    y_true = np.array([
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [0, 1, 0, 0],

        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0],

        [0, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0],

        [0, 0, 0, 1],
        [0, 0, 0, 1],
        [0, 0, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 1, 0],

        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],
        [0, 1, 0, 0],

        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],
        [1, 0, 0, 0],

        [1, 0, 0, 0],
        [0, 0, 0, 0],  # start 0-padding
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0]
    ])

    y_pred = np.array([
        [0.97320538, 0.00241233, 0.00655741, 0.01782488],
        [0.97320538, 0.00241233, 0.00655741, 0.01782488],
        [0.11245721, 0.83095266, 0.0413707, 0.01521943],  # error IG -> UTR
        [0.11245721, 0.83095266, 0.0413707, 0.01521943],  # error IG -> UTR
        [0.11245721, 0.83095266, 0.0413707, 0.01521943],

        [0.11245721, 0.83095266, 0.0413707, 0.01521943],
        [0.0349529, 0.25826895, 0.70204779, 0.00473036],  # error UTR -> Exon
        [0.0349529, 0.25826895, 0.70204779, 0.00473036],
        [0.0349529, 0.25826895, 0.70204779, 0.00473036],
        [0.0349529, 0.25826895, 0.70204779, 0.00473036],

        [0.01203764, 0.08894682, 0.24178252, 0.65723302],  # error Exon -> Intron
        [0.01203764, 0.08894682, 0.24178252, 0.65723302],  # error Exon -> Intron
        [0.0349529, 0.25826895, 0.70204779, 0.00473036],
        [0.97320538, 0.00241233, 0.00655741, 0.01782488],  # error Exon -> IG
        [0.97320538, 0.00241233, 0.00655741, 0.01782488],  # error Exon -> IG

        [0.0349529, 0.25826895, 0.70204779, 0.00473036],  # error Intron -> Exon
        [0.01203764, 0.08894682, 0.24178252, 0.65723302],
        [0.0349529, 0.25826895, 0.70204779, 0.00473036],
        [0.0349529, 0.25826895, 0.70204779, 0.00473036],
        [0.11245721, 0.83095266, 0.0413707, 0.01521943],  # error Exon -> UTR

        [0.11245721, 0.83095266, 0.0413707, 0.01521943],
        [0.11245721, 0.83095266, 0.0413707, 0.01521943],
        [0.11245721, 0.83095266, 0.0413707, 0.01521943],
        [0.97320538, 0.00241233, 0.00655741, 0.01782488],  # error UTR -> IG
        [0.97320538, 0.00241233, 0.00655741, 0.01782488],  # error UTR -> IG

        [0.97320538, 0.00241233, 0.00655741, 0.01782488],
        [0.97320538, 0.00241233, 0.00655741, 0.01782488],
        [0.97320538, 0.00241233, 0.00655741, 0.01782488],
        [0.97320538, 0.00241233, 0.00655741, 0.01782488],
        [0.97320538, 0.00241233, 0.00655741, 0.01782488],

        [0.97320538, 0.00241233, 0.00655741, 0.01782488],
        [0.0320586, 0.08714432, 0.23688282, 0.64391426],  # start 0-padding
        [0.0320586, 0.08714432, 0.23688282, 0.64391426],
        [0.0320586, 0.08714432, 0.23688282, 0.64391426],
        [0.0320586, 0.08714432, 0.23688282, 0.64391426],
        [0.0320586, 0.08714432, 0.23688282, 0.64391426]
    ])

    sample_weights = np.sum(y_true, axis=1)  # works bc, y_true is padded with ones

    cm_true = np.array([
        [8, 2, 0, 0],
        [2, 5, 1, 0],
        [2, 1, 6, 2],
        [0, 0, 1, 1]
    ])

    cm = ConfusionMatrixGenic()
    # add data in two parts
    cm.count_and_calculate_one_batch(y_true[:15], y_pred[:15], sample_weights[:15])
    cm.count_and_calculate_one_batch(y_true[15:], y_pred[15:], sample_weights[15:])
    print(cm.cm)
    assert np.array_equal(cm_true, cm.cm)

    # test normalization
    cm_true_normalized = np.array([
        [8 / 10, 2 / 10, 0, 0],
        [2 / 8, 5 / 8, 1 / 8, 0],
        [2 / 11, 1 / 11, 6 / 11, 2 / 11],
        [0, 0, 1 / 2, 1 / 2]
    ])

    assert np.allclose(cm_true_normalized, cm._get_normalized_cm())

    # argmax and filter y_true and y_pred
    y_true, y_pred = ConfusionMatrix._remove_masked_bases(y_true, y_pred, sample_weights)
    y_pred = ConfusionMatrix._argmax_y(y_pred)
    y_true = ConfusionMatrix._argmax_y(y_true)

    # test other metrics
    precision_true, recall_true, f1_true, _ = f1_scores(y_true, y_pred)
    scores = cm._get_scores()

    one_col_values = list(scores.values())[:4]  # excluding composite metrics
    assert np.allclose(precision_true, np.array([s['precision'] for s in one_col_values]))
    assert np.allclose(recall_true, np.array([s['recall'] for s in one_col_values]))
    assert np.allclose(f1_true, np.array([s['f1'] for s in one_col_values]))

    # test legacy cds metrics
    # essentially done in the same way as in ConfusionMatrix.py but copied here in case
    # it changes
    tp_cds = cm_true[2, 2] + cm_true[3, 3] + cm_true[2, 3] + cm_true[3, 2]
    fp_cds = cm_true[0, 2] + cm_true[1, 2] + cm_true[0, 3] + cm_true[1, 3]
    fn_cds = cm_true[2, 0] + cm_true[2, 1] + cm_true[3, 0] + cm_true[3, 1]
    cds_true = ConfusionMatrix._precision_recall_f1(tp_cds, fp_cds, fn_cds)
    assert np.allclose(cds_true[0], scores['legacy_cds']['precision'])
    assert np.allclose(cds_true[1], scores['legacy_cds']['recall'])
    assert np.allclose(cds_true[2], scores['legacy_cds']['f1'])

    # test subgenic metrics
    tp_genic = cm_true[2, 2] + cm_true[3, 3]
    fp_genic = (cm_true[0, 2] + cm_true[1, 2] + cm_true[3, 2] +
                cm_true[0, 3] + cm_true[1, 3] + cm_true[2, 3])
    fn_genic = (cm_true[2, 0] + cm_true[2, 1] + cm_true[2, 3] +
                cm_true[3, 0] + cm_true[3, 1] + cm_true[3, 2])
    genic_true = ConfusionMatrix._precision_recall_f1(tp_genic, fp_genic, fn_genic)
    assert np.allclose(genic_true[0], scores['sub_genic']['precision'])
    assert np.allclose(genic_true[1], scores['sub_genic']['recall'])
    assert np.allclose(genic_true[2], scores['sub_genic']['f1'])

    # test genic metrics
    tp_genic = cm_true[1, 1] + cm_true[2, 2] + cm_true[3, 3]
    fp_genic = (cm_true[0, 1] + cm_true[2, 1] + cm_true[3, 1] +
                cm_true[0, 2] + cm_true[1, 2] + cm_true[3, 2] +
                cm_true[0, 3] + cm_true[1, 3] + cm_true[2, 3])
    fn_genic = (cm_true[1, 0] + cm_true[1, 2] + cm_true[1, 3] +
                cm_true[2, 0] + cm_true[2, 1] + cm_true[2, 3] +
                cm_true[3, 0] + cm_true[3, 1] + cm_true[3, 2])
    genic_true = ConfusionMatrix._precision_recall_f1(tp_genic, fp_genic, fn_genic)
    assert np.allclose(genic_true[0], scores['genic']['precision'])
    assert np.allclose(genic_true[1], scores['genic']['recall'])
    assert np.allclose(genic_true[2], scores['genic']['f1'])

    # test accuracy
    acc_true = accuracy_score(y_pred, y_true)
    assert np.allclose(acc_true, cm._total_accuracy())


def test_gene_lengths():
    """Tests the '/data/gene_lengths' array"""
    _, controller, _ = setup_dummyloci()
    # dump the whole db in chunks into a .h5 file
    controller.export(chunk_size=5000, one_hot=True, longest_only=False)

    f = h5py.File(H5_OUT_FILE, 'r')
    gl = f['/data/gene_lengths']
    y = f['/data/y']

    assert len(gl) == 6  # one for each coord and strand (incl. unannotated coord #3)

    # check if there is a value > 0 wherever there is something genic
    for i in range(len(gl)):
        genic_gl = gl[i] > 0
        utr_y = np.all(y[i] == [0, 1, 0, 0], axis=-1)
        exon_y = np.all(y[i] == [0, 0, 1, 0], axis=-1)
        intron_y = np.all(y[i] == [0, 0, 0, 1], axis=-1)
        genic_y = np.logical_or(np.logical_or(utr_y, exon_y), intron_y)
        assert np.array_equal(genic_gl, genic_y)

    # first coord plus strand (test cases 1-3)
    assert np.array_equal(gl[0][:400], np.full((400,), 400, dtype=np.uint32))
    assert np.array_equal(gl[0][400:1199], np.full((1199 - 400,), 0, dtype=np.uint32))
    assert np.array_equal(gl[0][1199:1400], np.full((1400 - 1199,), 0, dtype=np.uint32))  # no gene length for non-coding (by default)

    # second coord plus strand (test cases 5-6)
    assert np.array_equal(gl[2][:300], np.full((300,), 300, dtype=np.uint32))
    assert np.array_equal(gl[2][300:549], np.full((549 - 300,), 0, dtype=np.uint32))
    assert np.array_equal(gl[2][549:750], np.full((750 - 549,), 201, dtype=np.uint32))

    # second coord minus strand (test cases 7-8)
    # check 0-padding
    assert np.array_equal(gl[3][-(5000 - 1755):], np.full((5000 - 1755,), 0, dtype=np.uint32))
    # check genic regions
    gl_3 = np.flip(gl[3])[5000 - 1755:]
    assert np.array_equal(gl_3[:949], np.full((949,), 0, dtype=np.uint32))
    assert np.array_equal(gl_3[949:1350], np.full((1350 - 949,), 401, dtype=np.uint32))
    assert np.array_equal(gl_3[1350:1549], np.full((1549 - 1350,), 0, dtype=np.uint32))
    assert np.array_equal(gl_3[1549:1750], np.full((1750 - 1549,), 201, dtype=np.uint32))
    f.close()


def test_seqids_start_ends():
    _, controller, _ = setup_dummyloci()
    controller.export(chunk_size=400, one_hot=False, longest_only=False)

    f = h5py.File(H5_OUT_FILE, 'r')
    seqids = f['/data/seqids'][:]
    start_ends = f['/data/start_ends'][:]

    seqids_true = np.concatenate([np.full((10,), b'1', dtype=seqids.dtype),
                                  np.full((10,), b'2', dtype=seqids.dtype),
                                  np.full((2,), b'3', dtype=seqids.dtype)])
    assert np.array_equal(seqids, seqids_true)

    start_ends_1 = [[0, 400], [400, 800], [800, 1200], [1200, 1600], [1600, 1801]]
    start_ends_2 = start_ends_1.copy()
    start_ends_2[-1] = [1600, 1755]
    start_ends_3 = [[0, 300]]
    start_ends_true = []

    for se in [start_ends_1, start_ends_2, start_ends_3]:
        start_ends_true += se  # plus strand
        # minus strand, reverse both order of chunks as well as order inside chunks coords
        start_ends_true += [[end, start] for start, end in se[::-1]]
    assert np.array_equal(start_ends, np.array(start_ends_true, dtype=start_ends.dtype))


def test_phases():
    """Tests the output of phase, which should be encoded for every cds base"""
    def next_phase(p):
        p -= 1
        if p < 0:
            p = 2
        return p

    def check_phase_in_cds(phases, introns, is_plus, phase=0):
        assert np.all(phases[introns][:, 0] == 1)  # if there is no phase in introns
        # take from 1 here, and remove introns, so that the phase can be literally interpreted
        # i.e. index 0 is phase 0, 1 is 1, 2 is 2
        coding_phases = phases[~introns, 1:]
        # phase is defined as how many bp do you need to remove from the start of the sequence, until
        # you're back at phase 0 / a codon start. So basically it goes 0, 2, 1, 0, 2, 1, 0, 2, 1, 0 ...
        # Naive test following that pattern.
        rolling_phase = phase
        for phase_enc in coding_phases:
            assert phase_enc[rolling_phase] == 1
            rolling_phase = next_phase(rolling_phase)

    _, controller, _ = setup_dummyloci()
    # dump the whole db in chunks into a .h5 file
    controller.export(chunk_size=5000, one_hot=True, longest_only=True)

    f = h5py.File(H5_OUT_FILE, 'r')
    ph = f['/data/phases'][:]
    y = f['/data/y'][:]
    padding = ~np.any(y == 1, axis=2)

    # check if phases is a valid one hot encoding
    assert np.all(np.count_nonzero(ph[~padding], axis=1) == 1)

    cds_regions_plus = [
        (0, slice(10, 301)),  # first chunk, 10:301 bases for the longest cds region of case 1
        (0, slice(1610, 1795)),
        (2, slice(39, 182)),
        (2, slice(524, 725)),
    ]

    # change coordinates on minus strand as we changed direction during numerification
    chunk_3_len = np.count_nonzero(padding[3] == 0)
    cds_regions_minus = [
        (3, slice(chunk_3_len - 1350, chunk_3_len - 974)),
        (3, slice(chunk_3_len - 1725, chunk_3_len - 1574)),
    ]

    for i, region in enumerate(cds_regions_plus):
        phase = 0 if i != 3 else 1  # the 4th cds region has phase 1 (this should be 'test case 6'?)
        check_phase_in_cds(ph[region], y[region][..., 3].astype(bool), True, phase)
    for region in cds_regions_minus:
        check_phase_in_cds(ph[region], y[region][..., 3].astype(bool), False)

    # check if number of bases in phase encoding that are non-default matches number of cds bases
    total_cds_len = 0
    for region in cds_regions_plus + cds_regions_minus:
        total_cds_len += len(y[region])
    n_phase_bases = np.count_nonzero(ph[~padding][:, 0] == 0)
    n_intron_bases = np.count_nonzero(y[~padding][:, 3] == 1)
    assert total_cds_len - n_intron_bases == n_phase_bases


# Setup dummy sequence with different feature transitions
def setup_feature_transitions():
    sess = mk_memory_session()
    genome = Genome()
    coord = Coordinate(genome=genome, sequence='A' * 720, length=720, seqid='a')
    s1 = SuperLocus()
    transcript = geenuff.orm.Transcript(super_locus=s1)
    piece = geenuff.orm.TranscriptPiece(transcript=transcript, position=0)
    transcript_feature_tr = geenuff.orm.Feature(start=41,
                                                end=671,
                                                is_plus_strand=True,
                                                type=geenuff.types.GEENUFF_TRANSCRIPT,
                                                start_is_biological_start=True,
                                                end_is_biological_end=True,
                                                coordinate=coord)
    transcript_feature_cds = geenuff.orm.Feature(start=131,
                                                 end=401,
                                                 is_plus_strand=True,
                                                 type=geenuff.types.GEENUFF_CDS,
                                                 start_is_biological_start=True,
                                                 end_is_biological_end=True,
                                                 phase=0,
                                                 coordinate=coord)
    transcript_feature_intron1 = geenuff.orm.Feature(start=221,
                                                     end=311,
                                                     is_plus_strand=True,
                                                     type=geenuff.types.GEENUFF_INTRON,
                                                     start_is_biological_start=True,
                                                     end_is_biological_end=True,
                                                     coordinate=coord)
    transcript_feature_intron2 = geenuff.orm.Feature(start=491,
                                                     end=581,
                                                     is_plus_strand=True,
                                                     type=geenuff.types.GEENUFF_INTRON,
                                                     start_is_biological_start=True,
                                                     end_is_biological_end=True,
                                                     coordinate=coord)
    transcript_feature_tr2 = geenuff.orm.Feature(start=705,
                                                 end=720,
                                                 is_plus_strand=True,
                                                 type=geenuff.types.GEENUFF_TRANSCRIPT,
                                                 start_is_biological_start=True,
                                                 end_is_biological_end=True,
                                                 coordinate=coord)

    piece.features = [transcript_feature_tr, transcript_feature_cds, transcript_feature_intron1,
                      transcript_feature_intron2, transcript_feature_tr2]

    sess.add_all([genome, coord, s1, transcript, piece, transcript_feature_tr, transcript_feature_cds,
                  transcript_feature_intron1, transcript_feature_intron2, transcript_feature_tr2])
    sess.commit()
    return sess, coord


def test_transition_encoding_and_weights():
    """Tests encoding of feature transitions, usage of transition weights and stretched weights"""
    _, coord = setup_feature_transitions()
    numerifier = AnnotationNumerifier(coord=coord,
                                      features=coord.features,
                                      max_len=1000,
                                      one_hot=False)
    nums = numerifier.coord_to_matrices()[-1]

    # expected output of AnnotationNumerifier.coord_to_matrices()
    expect_plus_strand_encoding = np.zeros((720, 6)).astype(np.int8)
    expect_plus_strand_encoding[40:42, 0] = 1  # UTR 1 +
    expect_plus_strand_encoding[670:672, 3] = 1  # UTR 2 -
    expect_plus_strand_encoding[130:132, 1] = 1  # CDS +
    expect_plus_strand_encoding[400:402, 4] = 1  # CDS -
    expect_plus_strand_encoding[220:222, 2] = 1  # First Intron +
    expect_plus_strand_encoding[310:312, 5] = 1  # First Intron -
    expect_plus_strand_encoding[490:492, 2] = 1  # Second Intron +
    expect_plus_strand_encoding[580:582, 5] = 1  # Second Intron -
    expect_plus_strand_encoding[704:706, 0] = 1  # Start of 2. 5prime UTR

    expect_minus_strand_encoding = np.zeros((720, 6)).astype(np.int8)

    assert np.array_equal(nums['plus'][0], expect_plus_strand_encoding)
    assert np.array_equal(nums['minus'][0], expect_minus_strand_encoding)

    # initializing variables + reshape
    transitions_plus_strand = np.array(nums['plus']).reshape((8, 9, 10, 6))
    transitions_minus_strand = np.array(nums['minus']).reshape((8, 9, 10, 6))
    transition_weights = [10, 20, 30, 40, 50, 60]
    stretch = 0  # if stretch is not called the default value is 0

    # tw = Transition weights; xS = xStretch
    applied_tw_no_stretch_plus = LSTMSequence._squish_tw_to_sw(transitions_plus_strand, transition_weights, stretch)
    applied_tw_no_stretch_minus = LSTMSequence._squish_tw_to_sw(transitions_minus_strand, transition_weights, stretch)
    expect_tw_minus = np.ones((8, 9))
    assert np.array_equal(expect_tw_minus, applied_tw_no_stretch_minus)

    expect_no_stretch = np.array([
        [1, 1, 1, 1, 10, 1, 1, 1, 1],
        [1, 1, 1, 1, 20, 1, 1, 1, 1],
        [1, 1, 1, 1, 30, 1, 1, 1, 1],
        [1, 1, 1, 1, 60, 1, 1, 1, 1],
        [1, 1, 1, 1, 50, 1, 1, 1, 1],
        [1, 1, 1, 1, 30, 1, 1, 1, 1],
        [1, 1, 1, 1, 60, 1, 1, 1, 1],
        [1, 1, 1, 1, 40, 1, 1, 10, 1]
    ])
    assert np.array_equal(applied_tw_no_stretch_plus, expect_no_stretch)

    # transition weights are spread over sample weights in each direction
    # amplifies area around the transition by:
    # [ tw/2**3 [ tw/2**2 [ tw/2**1 [ tw ] tw/2**1 ] tw/2**2] ..
    stretch = 3
    expect_3_stretch = np.array([
        [1, 1.25, 2.5, 5, 10, 5, 2.5, 1.25, 1],
        [1, 2.5, 5, 10, 20, 10, 5, 2.5, 1],
        [1, 3.75, 7.5, 15, 30, 15, 7.5, 3.75, 1],
        [1, 7.5, 15, 30, 60, 30, 15, 7.5, 1],
        [1, 6.25, 12.5, 25, 50, 25, 12.5, 6.25, 1],
        [1, 3.75, 7.5, 15, 30, 15, 7.5, 3.75, 1],
        [1, 7.5, 15, 30, 60, 30, 15, 7.5, 1],
        [1, 5, 10, 20, 40, 20, 5, 10, 5],  # works as intended,
        # but should be [.., 40, 20, 10, 10, 5]
        # should not be a problem for smaller s_tw values
        # due to feature transition frequency
    ])
    applied_tw_3_stretch_plus = LSTMSequence._squish_tw_to_sw(transitions_plus_strand, transition_weights, stretch)
    assert np.array_equal(applied_tw_3_stretch_plus, expect_3_stretch)


### RNAseq / coverage or scoring related (evaluation)
def test_contiguous_bits():
    """confirm correct splitting at sequence breaks or after filtering when data is chunked for mem efficiency"""

    h5 = h5py.File(EVAL_H5, 'r')
    bits_plus, bits_minus = rnaseq.find_contiguous_segments(h5, start_i=0, end_i=h5['data/start_ends'].shape[0],
                                                            chunk_size=h5['evaluation/coverage'].shape[1])

    assert [len(x.start_ends) for x in bits_plus] == [2, 1, 1, 1]
    assert [len(x.start_ends) for x in bits_minus] == [1, 2, 1, 1]
    assert [x.start_i_h5 for x in bits_plus] == [0, 2, 3, 4]
    assert [x.end_i_h5 for x in bits_plus] == [2, 3, 4, 5]
    assert [x.start_i_h5 for x in bits_minus] == [5, 6, 8, 9]
    assert [x.end_i_h5 for x in bits_minus] == [6, 8, 9, 10]

    for b in bits_plus:
        print(b)
    print('---- and now minus ----')
    for b in bits_minus:
        print(b)
    h5.close()


def test_coverage_in_bits():
    # coverage arrays have the total sequence length [0, 133333) and data for every point
    # just needs to be divvied up to match the bits of sequence that exist in the h5 start_ends
    length = 133333
    coverage = np.arange(length)
    rev_coverage = np.arange(10 ** 6, 10 ** 6 + length, 1)
    print(coverage, rev_coverage)
    h5 = h5py.File(EVAL_H5, 'a')
    start_ends = h5['data/start_ends'][:]
    print(start_ends)
    chunk_size = h5['evaluation/coverage'].shape[1]
    bits_plus, bits_minus = rnaseq.find_contiguous_segments(h5, start_i=0, end_i=h5['data/start_ends'].shape[0],
                                                            chunk_size=chunk_size)
    rnaseq.write_in_bits(coverage, bits_plus, h5['evaluation/coverage'], chunk_size)
    rnaseq.write_in_bits(rev_coverage, bits_minus, h5['evaluation/coverage'], chunk_size)
    for i, (start, end) in enumerate(start_ends):
        cov_chunk = h5['evaluation/coverage'][i]
        assert end != start
        print(start, end, h5['evaluation/coverage'][i])
        if start < end:
            pystart, pyend = start, end
            is_plus = True
        else:
            pystart, pyend = end, start
            is_plus = False
        # remember, forward coverage was set to be the index, and rev coverage 1mil + index before (forward dir)
        # padding stays -1
        if pyend == length:
            # edge case, +strand, end of seq
            if is_plus:
                assert cov_chunk[0] == pystart
                assert cov_chunk[length % chunk_size - 1] == length - 1
                assert cov_chunk[length % chunk_size] == -1
                assert cov_chunk[-1] == -1
            # edge case, -strand, end of seq (or maybe start?... but it's handled more like an end)
            else:
                # this is flipped, and then padded right... not contiguous and not like the others... -_-
                # padding separates the end piece, from the next otherwise contiguous segment
                assert cov_chunk[-1] == -1
                assert cov_chunk[length % chunk_size] == -1
                assert cov_chunk[length % chunk_size - 1] == pystart + 10 ** 6
                assert cov_chunk[0] == length - 1 + 10 ** 6
        # normal, +strand
        elif is_plus:
            assert cov_chunk[0] == pystart
            assert cov_chunk[-1] == pyend - 1
        # normal, -strand
        else:
            assert cov_chunk[-1] == pystart + 10 ** 6
            assert cov_chunk[0] == pyend + 10 ** 6 - 1
    h5.close()


def test_super_chunking4write():
    """Tests that the exact same h5 is produced, regardless of how many super-chunks it is written in"""
    _, controller, _ = setup_dummyloci()
    # dump the whole db in chunks into a .h5 file
    n_writing_chunks = controller.export(chunk_size=500, one_hot=True, longest_only=False,
                                         write_by=10_000_000_000)  # write by left large enough to yield just once

    f = h5py.File(H5_OUT_FILE, 'r')
    y0 = np.array(f['/data/y'][:])
    se0 = np.array(f['/data/start_ends'][:])
    seqids0 = np.array(f['/data/seqids'][:])
    species0 = np.array(f['/data/species'][:])
    gl0 = np.array(f['/data/gene_lengths'][:])
    phases0 = np.array(f['/data/phases'][:])
    x0 = np.array(f['/data/X'][:])

    assert n_writing_chunks == 6  # 2 per coordinate
    _, controller, _ = setup_dummyloci()
    # dump the whole db in chunks into a .h5 file
    n_writing_chunks = controller.export(chunk_size=500, longest_only=False,
                                         write_by=1000)  # write by should result in multiple super-chunks

    f = h5py.File(H5_OUT_FILE, 'r')
    y1 = np.array(f['/data/y'][:])
    se1 = np.array(f['/data/start_ends'][:])
    seqids1 = np.array(f['/data/seqids'][:])
    species1 = np.array(f['/data/species'][:])
    gl1 = np.array(f['/data/gene_lengths'][:])
    phases1 = np.array(f['/data/phases'][:])
    x1 = np.array(f['/data/X'][:])
    assert np.all(se0 == se1)
    assert np.all(seqids0 == seqids1)
    assert np.all(species0 == species1)
    assert np.all(x0 == x1)
    assert np.all(y0 == y1)
    assert np.all(gl0 == gl1)
    assert np.all(phases0 == phases1)
    # this makes sure it's being writen in multiple pieces at all
    # 4 for each of the two 'longer' coordinates (1000 < 2000 in length) + 2 for short & featureless coord
    assert n_writing_chunks == 10

    # finally, make sure it fails on invalid write_by val
    _, controller, _ = setup_dummyloci()
    # dump the whole db in chunks into a .h5 file
    # this should now run through as before, as write_by should auto-truncate
    # to a valid value
    controller.export(chunk_size=500, one_hot=True, longest_only=False,
                      write_by=1001)  # write by should result in multiple super-chunks
    assert n_writing_chunks == 10


def test_rangefinder():
    _, controller, _ = setup_dummyloci()
    # dump the whole db in chunks into a .h5 file
    n_writing_chunks = controller.export(chunk_size=500, one_hot=True,
                                         longest_only=False, write_by=10_000_000_000)
    f = h5py.File(H5_OUT_FILE, 'r')
    sp_seqid_ranges = helpers.get_sp_seq_ranges(f)
    seqid_ranges = {b'1': [0, 8], b'2': [8, 16], b'3': [16, 18]}
    assert sp_seqid_ranges == {b'dummy': {'start': 0, 'seqids': seqid_ranges, 'end': 18}}


def test_confident_onecategory():
    pred_chunk = np.full(fill_value=0., shape=(100, 4), dtype=np.float32)
    # identify a sharp transition 0 -> 1
    pred_chunk[:50, 0] = 1.
    pred_chunk[50:, 1] = 1.
    chunks = list(helpers.find_confident_single_class_regions(pred_chunk))
    assert chunks == [(0, 49), (50, 100)]
    # identify a more "gradual" transition 0 -> 0.5 -> 1
    pred_chunk[50, 0:2] = 0.5
    chunks = list(helpers.find_confident_single_class_regions(pred_chunk))
    assert chunks == [(0, 49), (51, 100)]
    # identify an actually gradual transition
    pred_chunk[:, 0] = np.sin([x / 100 * np.pi / 2 for x in range(0, 100)])
    pred_chunk[:, 1] = 1 - pred_chunk[:, 0]
    chunks = list(helpers.find_confident_single_class_regions(pred_chunk))
    assert chunks == [(0, 16), (54, 100)]
    # identify consistently held confidence
    pred_chunk[:, 0] = 1
    pred_chunk[:, 1] = 0
    chunks = list(helpers.find_confident_single_class_regions(pred_chunk))
    assert chunks == [(0, 100)]
    # identify a dip in confidence (not critical behaviour, but currently expected)
    pred_chunk[50, 0:2] = 0.5
    chunks = list(helpers.find_confident_single_class_regions(pred_chunk))
    assert chunks == [(0, 49), (51, 100)]
    # identify confident region followed by consistent lack of confidence
    pred_chunk[50:, :] = 0.25
    chunks = list(helpers.find_confident_single_class_regions(pred_chunk))
    assert chunks == [(0, 49)]
    # properly handle complete lack of confidence (aka return empty)
    pred_chunk[:, :] = 0.25
    chunks = list(helpers.find_confident_single_class_regions(pred_chunk))
    assert chunks == []


def test_predictions_realdata():
    """test that _all_ predictions end up being the class from hints across real data as done in predictions2hints"""
    # what this decidedly does not test is going all the way to and from gff coordinates!
    data = h5py.File('testdata/mini_test_data.h5', 'r')
    preds = h5py.File('testdata/mini_test_preds.h5', 'r')
    get_contiguous_ranges = helpers.get_contiguous_ranges
    read_in_chunks = helpers.read_in_chunks
    find_confident_single_class_regions = helpers.find_confident_single_class_regions
    divvy_by_confidence = helpers.divvy_by_confidence
    hint_step_key = [(100, 10_000), (10, 500), (10, 500), (10, 500)]
    for contiguous_bit in get_contiguous_ranges(h5=data):
        for pred_chunk, start, end in read_in_chunks(preds, data, contiguous_bit['start_i'], contiguous_bit['end_i']):
            # break into pieces anywhere where the confidence drops or the category switches
            for start_conf, end_conf in find_confident_single_class_regions(pred_chunk):
                one_class_chunk = pred_chunk[start_conf:end_conf]
                # pad and break further, down to min size confidence is volatile or up to max if stable
                # use average prediction confidence as score
                for pre_hint in divvy_by_confidence(one_class_chunk, hint_step_key):
                    hint_start = pre_hint['start']
                    hint_end = pre_hint['end']
                    inputpred = pred_chunk[start_conf + hint_start:start_conf + hint_end]
                    assert np.all(np.argmax(inputpred, axis=1) == pre_hint['category'])


# overlapping
def test_ol_length_in_matches_out_sub_batch():
    """test that predictions length matches input length, after sliding window preds and overlapping, in sub batch"""
    x_dset = np.zeros(shape=(16, 20000, 4))
    indices_to_test = [(0,),
                       (0, 1, 2, 3),
                       (4, 5, 6, 7, 8, 9, 10, 11),
                       tuple(range(16))
                       ]
    offsets = [5000, 4000, 2000, 20000 // 3]
    for indices in indices_to_test:
        for ends in [True, False]:
            for offset in offsets:
                sb = overlap.SubBatch(h5_indices=indices, is_plus_strand=True, keep_start=None, keep_end=None,
                                      edge_handle_end=ends, edge_handle_start=ends,
                                      overlap_offset=offset, chunk_size=20000)
                # below is close enough, since we're ignoring content here, and only care about dimensions
                preds = sb.mk_sliding_overlaps_for_data_sub_batch(data_sub_batch=x_dset[np.array(sb.h5_indices)])
                overlapped = sb._overlap_preds(preds, core_length=10000)
                assert len(indices) == overlapped.shape[0]
                assert overlapped.shape[1:] == (20000, 4)


def test_ol_identical_preds_return_ori():
    x_dsets = [np.random.rand(16, 20000, 4) for _ in range(10)]
    indices_to_test = [(0,), (1,), (4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
                       (1, 2), (3, 4, 5), (6, 7, 8, 9, 10, 11), tuple(range(8))]
    for x_dset in x_dsets:
        for indices in indices_to_test:
            for core_length in [5020, 8000, 10000, 12000, 18000, 20000]:
                sb = overlap.SubBatch(h5_indices=indices, overlap_offset=5000, chunk_size=20000,  
                                      edge_handle_start=False, edge_handle_end=False, is_plus_strand=True)
                # just checking identity, doesn't matter whether we actually have preds
                raw_preds = sb.mk_sliding_overlaps_for_data_sub_batch(data_sub_batch=x_dset[np.array(sb.h5_indices)])
                expect = x_dset[np.array(indices)]
                assert np.allclose(expect, sb._overlap_preds(raw_preds, core_length=core_length))
    # concatenation of three with end handling
    x_dset = x_dsets[0]
    sbs = []
    indices_realistic = [tuple(range(7)),
                         tuple(range(5, 13)),
                         tuple(range(11, 16))]
    edge_handling = [(True, False), (False, False), (False, True)]
    for indices, edges in zip(indices_realistic, edge_handling):
        sbs.append(
            overlap.SubBatch(h5_indices=indices, overlap_offset=5000, chunk_size=20000, is_plus_strand=True,
                             edge_handle_start=edges[0], edge_handle_end=edges[1])
        )
    preds = []
    for sb in sbs:
        raw_preds = sb.mk_sliding_overlaps_for_data_sub_batch(data_sub_batch=x_dset[np.array(sb.h5_indices)])
        ol_preds = sb.overlap_and_edge_handle_preds(raw_preds, core_length=10000)
        preds.append(ol_preds)
    fin_preds = np.concatenate(preds)
    assert np.allclose(fin_preds, x_dset)


def test_ol_indivisible_chunksize():
    """confirms input -> output holds for overlap offsets that don't divide chunksize"""
    x_dsets = [np.random.rand(16, 20000, 4) for _ in range(10)]
    indices_to_test = [(0,), (1,), (4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
                       (1, 2), (3, 4, 5), (6, 7, 8, 9, 10, 11), tuple(range(8))]
    for x_dset in x_dsets:
        for indices in indices_to_test:
            for core_length in [8000, 20000]:
                for oo in [3000, 4245, 6000]:
                    sb = overlap.SubBatch(h5_indices=indices, overlap_offset=oo, chunk_size=20000, 
                                          edge_handle_start=False, edge_handle_end=False, is_plus_strand=True)
                    # just checking identity, doesn't matter whether we actually have preds
                    raw_preds = sb.mk_sliding_overlaps_for_data_sub_batch(data_sub_batch=x_dset[np.array(sb.h5_indices)])
                    expect = x_dset[np.array(indices)]
                    assert np.allclose(expect, sb._overlap_preds(raw_preds, core_length=core_length))

def test_ol_pred_overlap_and_weighting():
    sb = overlap.SubBatch(h5_indices=(0, 1),
                          overlap_offset=5000, chunk_size=20000,
                          edge_handle_start=False, edge_handle_end=False, is_plus_strand=True)
    # this should produce length 5 X, some test predictions, with easy to calc output
    # (each char is 5k, number is index with 1.)
    # 0 0 0 0
    #   1 1 1 1
    #     2 2 2 2
    #       3 3 3 3
    #         0 0 0 0
    preds = np.zeros(shape=(5, 20000, 4))
    for i, argmax in zip(range(5), (0, 1, 2, 3, 0)):
        preds[i, :, argmax] = 1
    # with core_length 20000 (no trimming), this should overlap to array below divided by column sums
    # 0: 1 1 1 1 1 1 1 1
    # 1: 0 1 1 1 1 0 0 0
    # 2: 0 0 1 1 1 1 0 0
    # 3: 0 0 0 1 1 1 1 0
    expect = np.zeros(shape=(40000, 4))
    expect[:, 0] = 1.
    expect[5000:25000, 1] = 1
    expect[10000:30000, 2] = 1
    expect[15000:35000, 3] = 1
    expect = expect / np.sum(expect, axis=1).reshape((-1, 1))
    expect = expect.reshape((2, 20000, 4))

    overlapped = sb._overlap_preds(preds, core_length=20000)
    assert np.allclose(expect, overlapped)

    # with core_length 10000, this should overlap to array below divided by column sums
    # were x = 0, but indicates what got trimmed
    # 0: 1 1 1 x x 1 1 1
    # 1: 0 x 1 1 x 0 0 0
    # 2: 0 0 x 1 1 x 0 0
    # 3: 0 0 0 x 1 1 x 0
    expect = np.zeros(shape=(40000, 4))
    expect[0:15000, 0] = 1.
    expect[25000:40000, 0] = 1
    expect[10000:20000, 1] = 1
    expect[15000:25000, 2] = 1
    expect[20000:30000, 3] = 1
    expect = expect / np.sum(expect, axis=1).reshape((-1, 1))
    expect = expect.reshape((2, 20000, 4))

    overlapped = sb._overlap_preds(preds, core_length=10000)
    assert np.allclose(expect, overlapped)


def test_ol_overlap_seq_helper():
    """semi-integrated testing that no bit of sequence is added / lost """

    def mk_cb(start_i, end_i):
        # only that which is used
        return {"is_plus_strand": True, "start_i": start_i, "end_i": end_i}

    def cmp_one(dummy_xpred, contiguous_ranges):
        ol_helper = overlap.OverlapSeqHelper(contiguous_ranges=contiguous_ranges,
                                             chunk_size=20000, max_batch_size=32, 
                                             overlap_offset=5000, core_length=10000)
        preds_out = []
        print(ol_helper.adjusted_epoch_length())
        for batch_idx in range(ol_helper.adjusted_epoch_length()):
            raw_preds = ol_helper.make_input(batch_idx,
                                             data_batch=dummy_xpred[ol_helper.h5_indices_of_batch(batch_idx)])
            ol_preds = ol_helper.overlap_predictions(batch_idx, raw_preds)
            preds_out.append(ol_preds)
        fin_predictions = np.concatenate(preds_out)
        print(fin_predictions.shape, dummy_xpred.shape)
        assert np.allclose(fin_predictions, dummy_xpred)

    for seq_len in range(1, 15):
        # bits for 5 sequences of varying length
        contiguous_ranges = [mk_cb(seq_len * i, seq_len * (i + 1)) for i in range(5)]
        dummy_xpred = np.random.rand(5 * seq_len, 20000, 4)
        cmp_one(dummy_xpred, contiguous_ranges)

    # ascending
    contiguous_ranges = []
    cumulative = 0
    for i in range(1, 20):
        contiguous_ranges.append(mk_cb(cumulative, cumulative + i))
        cumulative += i
    dummy_xpred = np.random.rand(cumulative, 20000, 4)
    cmp_one(dummy_xpred, contiguous_ranges)

    # descending
    contiguous_ranges = []
    cumulative = 0
    for j in range(0, 19):
        i = 20 - j
        contiguous_ranges.append(mk_cb(cumulative, cumulative + i))
        cumulative += i
    dummy_xpred = np.random.rand(cumulative, 20000, 4)
    cmp_one(dummy_xpred, contiguous_ranges)


def test_direct_fasta_export():
    fasta_controller = HelixerFastaToH5Controller('testdata/dummyloci.fa', FASTA_OUT_FILE)
    fasta_controller.export_fasta_to_h5(chunk_size=400, compression='gzip', multiprocess=True,
                                        species='dummy')

    _, geenuff_controller, _ = setup_dummyloci()
    # dump the whole db in chunks into a .h5 file
    geenuff_controller.export(chunk_size=400, one_hot=False, longest_only=False)

    h5_fasta = h5py.File(FASTA_OUT_FILE, 'r')
    h5_db = h5py.File(H5_OUT_FILE, 'r')

    # check if both have the same seqid/start_ends combinations - the ordering may vary
    X_fasta, X_db = h5_fasta['/data/X'][:], h5_db['/data/X'][:]
    seqids_fasta, seqids_db = h5_fasta['/data/seqids'][:], h5_db['/data/seqids'][:]
    start_ends_fasta, start_ends_db = h5_fasta['/data/start_ends'][:], h5_db['/data/start_ends'][:]
    assert len(X_fasta) == len(X_db)

    # generate lists we can then sort and compare
    fasta = [(i, s, se) for i, (s, se) in enumerate(zip(seqids_fasta, start_ends_fasta))]
    db = [(i, s, se) for i, (s, se) in enumerate(zip(seqids_db, start_ends_db))]
    fn_sort = lambda t: (t[1], t[2][0], t[2][1])
    fasta_sorted, db_sorted = sorted(fasta, key=fn_sort), sorted(db, key=fn_sort)

    for ((i, fasta_seqid, fasta_se), (j, db_seqid, db_se)) in zip(fasta_sorted, db_sorted):
        assert fasta_seqid == db_seqid
        assert fasta_se[0] == db_se[0] and fasta_se[1] == db_se[1]
        assert np.array_equal(X_fasta[i], X_db[j])






