import h5py
import argparse


def main(data, predictions, save_to):
    h5_data = h5py.File(data)
    h5_pred = h5py.File(predictions)
    h5_out = h5py.File(save_to, 'w')
    print(h5_data.id, h5_out.id)
    for key in h5_data.keys():
        bkey = key.encode('utf-8')
        print('copying {} from {}'.format(bkey, data))
        # generally: b'data', (b'evalualtion', b'scores')
        h5py.h5o.copy(h5_data.id, bkey, h5_out.id, bkey)
    for key in h5_pred.keys():
        bkey = key.encode('utf-8')
        print('copying {} from {}'.format(bkey, predictions))
        # generall: b'predictions'
        h5py.h5o.copy(h5_pred.id, bkey, h5_out.id, bkey)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--data', type=str, required=True,
                        help="input file with 'data/[X,y,species,seq=ids, start_ends, etc...]'")
    parser.add_argument('--predictions', type=str, required=True,
                        help="input file with 'predictions'")
    parser.add_argument('--out', type=str, help="output h5 file")
    args = parser.parse_args()
    main(args.data, args.predictions, args.out)
