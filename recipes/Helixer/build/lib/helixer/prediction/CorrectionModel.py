#! /usr/bin/env python3
import numpy as np

from tensorflow.keras.models import Model
from tensorflow.keras.layers import (Conv1D, LSTM, Dense, Bidirectional, MaxPooling1D, Dropout, Reshape,
                                     Activation, Input, BatchNormalization, Concatenate)
from HelixerModel import HelixerModel, HelixerSequence


class CorrectionSequence(HelixerSequence):
    def __init__(self, model, h5_file, mode, batch_size, shuffle):
        super().__init__(model, h5_file, mode, batch_size, shuffle)
        assert self.load_predictions, 'need --load-predictions for correction model'

    def __getitem__(self, idx):
        X, y, sw, transitions, predictions, _ = self._get_batch_data(idx)
        pool_size = self.model.pool_size

        if pool_size > 1:
            if y.shape[1] % pool_size != 0:
                # clip to maximum size possible with the pooling length
                overhang = y.shape[1] % pool_size
                X = X[:, :-overhang]
                y = y[:, :-overhang]
                sw = sw[:, :-overhang]
                predictions = predictions[:, :-overhang]
                if self.mode == 'train' and self.transition_weights is not None:
                    transitions = transitions[:, :-overhang]

            y = self._mk_timestep_pools_class_last(y)

            sw = sw.reshape((sw.shape[0], -1, pool_size))
            sw = np.logical_not(np.any(sw == 0, axis=2)).astype(np.int8)

            if self.mode == 'train':

                if self.class_weights is not None:
                    # class weights are additive for the individual timestep predictions
                    # giving even more weight to transition points
                    # class weights without pooling not supported yet
                    # cw = np.array([1.0, 1.2, 1.0, 0.8], dtype=np.float32)
                    cls_arrays = [np.any((y[:, :, :, col] == 1), axis=2) for col in range(4)]
                    cls_arrays = np.stack(cls_arrays, axis=2).astype(np.int8)
                    # add class weights to applicable timesteps
                    cw_arrays = np.multiply(cls_arrays, np.tile(self.class_weights, y.shape[:2] + (1,)))
                    cw = np.sum(cw_arrays, axis=2)
                    sw = np.multiply(cw, sw)

                # todo, while now compressed, the following is still 1:1 with LSTM model... --> HelixerModel
                if self.transition_weights is not None:
                    transitions = self._mk_timestep_pools_class_last(transitions)
                    # more reshaping and summing  up transition weights for multiplying with sample weights
                    sw_t = self.compress_tw(transitions)
                    sw = np.multiply(sw_t, sw)

        return [X, predictions], y, sw


class CorrectionModel(HelixerModel):
    def __init__(self):
        super().__init__()
        self.parser.add_argument('--x-cnn-layers', type=int, default=1)
        self.parser.add_argument('--x-filter-depth', type=int, default=32)
        self.parser.add_argument('--x-kernel-size', type=int, default=26)
        self.parser.add_argument('--pred-cnn-layers', type=int, default=1)
        self.parser.add_argument('--pred-filter-depth', type=int, default=32)
        self.parser.add_argument('--pred-kernel-size', type=int, default=26)
        self.parser.add_argument('--lstm-layers', type=int, default=1)
        self.parser.add_argument('--units', type=int, default=32)
        self.parser.add_argument('--pool-size', type=int, default=10)
        self.parser.add_argument('--x-dropout1', type=float, default=0.0)
        self.parser.add_argument('--pred-dropout1', type=float, default=0.0)
        self.parser.add_argument('--dropout2', type=float, default=0.0)
        self.parse_args()

    @staticmethod
    def sequence_cls():
        return CorrectionSequence

    def model(self):
        def _cnn_stack(x, cnn_layers, filter_depth, kernel_size, dropout):
            x = Conv1D(filters=filter_depth,
                       kernel_size=kernel_size,
                       padding="same",
                       activation="relu")(x)
            # if there are additional CNN layers
            for _ in range(cnn_layers - 1):
                x = BatchNormalization()(x)
                x = Conv1D(filters=filter_depth,
                           kernel_size=kernel_size,
                           padding="same",
                           activation="relu")(x)
            if self.pool_size > 1:
                x = Reshape((-1, self.pool_size * filter_depth))(x)
            if dropout > 0.0:
                x = Dropout(dropout)(x)
            return x

        overhang = self.shape_train[1] % self.pool_size
        X_input = Input(shape=(None, 4), dtype=self.float_precision, name='X_input')
        pred_input = Input(shape=(None, 4), dtype=self.float_precision, name='pred_input')

        x = _cnn_stack(X_input, self.x_cnn_layers, self.x_filter_depth, self.x_kernel_size, self.x_dropout1)
        x_pred = _cnn_stack(pred_input, self.pred_cnn_layers, self.pred_filter_depth,
                            self.pred_kernel_size, self.pred_dropout1)

        x = Concatenate(axis=-1)([x, x_pred])

        x = Bidirectional(LSTM(self.units, return_sequences=True))(x)
        for _ in range(self.lstm_layers - 1):
            x = Bidirectional(LSTM(self.units, return_sequences=True))(x)

        # do not use recurrent dropout, but dropout on the output of the LSTM stack
        if self.dropout2 > 0.0:
            x = Dropout(self.dropout2)(x)

        x = Dense(self.pool_size * 4)(x)
        x = Reshape((-1, self.pool_size, 4))(x)
        x = Activation('softmax', name='main')(x)

        outputs = [x]
        model = Model(inputs=[X_input, pred_input], outputs=outputs)
        return model

    def compile_model(self, model):
        losses = ['categorical_crossentropy']
        loss_weights = [1.0]

        model.compile(optimizer=self.optimizer,
                      loss=losses,
                      loss_weights=loss_weights,
                      sample_weight_mode='temporal')


if __name__ == '__main__':
    model = CorrectionModel()
    model.run()
