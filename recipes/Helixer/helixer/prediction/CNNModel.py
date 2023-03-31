#! /usr/bin/env python3
import random
import numpy as np
from keras.models import Sequential
from keras.layers import Conv1D, Dense, Flatten
from HelixerModel import HelixerModel, HelixerSequence


class CNNSequence(HelixerSequence):
# things in here may not work anymore
    def __getitem__(self, idx):
        usable_idx_slice = self.usable_idx[idx * self.batch_size:(idx + 1) * self.batch_size]
        X = np.stack(self.x_dset[sorted(list(usable_idx_slice))])  # got to provide a sorted list of idx
        y = np.stack(self.y_dset[sorted(list(usable_idx_slice))])
        return X, y


class CNNModel(HelixerModel):

    def __init__(self):
        super().__init__()
        self.parser.add_argument('--kernel-size', type=int, default=7)
        self.parser.add_argument('--final-kernel-size', type=int, default=128)
        self.parser.add_argument('--filter-depth', type=int, default=64)
        self.parser.add_argument('--n-layers', type=int, default=4)
        self.parse_args()

    def sequence_cls(self):
        return CNNSequence

    def model(self):
        model = Sequential()
        model.add(Conv1D(filters=self.filter_depth,
                         kernel_size=self.kernel_size,
                         input_shape=(self.shape_train[1], 4),
                         padding="same",
                         activation="relu"))

        # -2 because first and last have different dimensions
        for _ in range(self.n_layers - 2):
            model.add(Conv1D(filters=self.filter_depth,
                             kernel_size=self.kernel_size,
                             padding="same",
                             activation="relu"))

        model.add(Conv1D(filters=7,

                         kernel_size=self.final_kernel_size,
                         activation="relu",
                         padding="same"))
        return model

    def compile_model(self, model):
        model.compile(optimizer=self.optimizer,
                      loss='categorical_crossentropy',

                      metrics=['accuracy'])


if __name__ == '__main__':
    model = CNNModel()
    model.run()
