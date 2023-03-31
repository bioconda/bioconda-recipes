#! /usr/bin/env python3
import sys
import h5py
import random
import numpy as np
import tkinter as tk
import seaborn
import matplotlib
import argparse
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure

from helixer.export.numerify import AMBIGUITY_DECODE

class Visualization():
    def __init__(self, root, args):
        self.root = root
        self.args = args
        self.offset = 0  # of a sequence
        self.seq_index = 0

        # load and transform data
        self.h5_data = h5py.File(args.test_data, 'r')
        self.h5_predictions = h5py.File(args.predictions, 'r')

        # detect labels
        self.label_dim = self.h5_data['/data/y'].shape[-1]
        self.one_hot = self.label_dim > 3

        # set a few constants
        self.BASE_COUNT_X = 100
        self.BASE_COUNT_SCREEN = self.BASE_COUNT_X * args.n_rows
        self.MARGIN_BOTTOM = 100
        self.HEATMAP_SIZE_X = 1920
        self.PIXEL_SIZE = self.HEATMAP_SIZE_X // self.BASE_COUNT_X
        self.HEATMAP_SIZE_Y = self.PIXEL_SIZE * self.label_dim * (args.n_rows * 2)
        self.DPI = 96  # monitor specific

        # save n_seq and chunk_len from predictions as there are likely a tiny bit fewer
        # than labels, due to the data generator in keras
        self.n_seq = self.h5_predictions['/predictions'].shape[0]
        self.chunk_len = self.h5_predictions['/predictions'].shape[1]

        # set self.cutoff and self.chunk_len if things are not dividing nicely
        if self.chunk_len % self.BASE_COUNT_SCREEN > 0:
            self.cutoff = self.BASE_COUNT_SCREEN - (self.chunk_len % self.BASE_COUNT_SCREEN)
            self.chunk_len += self.cutoff
        else:
            self.cutoff = 0

        if self.args.exclude_errors:
            self.err_idx = np.squeeze(np.argwhere(np.array(self.h5_data['/data/err_samples']) == True))

        fully_intergenic_bool = self.h5_data['/data/fully_intergenic_samples']
        self.genic_indexes = np.squeeze(np.argwhere(np.array(fully_intergenic_bool) == False))
        self.load_sequence_infos()

        if self.args.exclude_errors:
            self.genic_indexes = np.setdiff1d(self.genic_indexes, self.err_idx)

        # set up GUI
        self.frame = tk.Frame(self.root)
        self.frame.pack()

        self.previous_button = tk.Button(self.frame, text='previous')
        self.previous_button.bind('<ButtonPress-1>', self.previous)
        self.previous_button.grid(row=0, column=0)

        self.next_button = tk.Button(self.frame, text='next')
        self.next_button.bind('<ButtonPress-1>', self.next)
        self.next_button.grid(row=0, column=1)

        self.next_genic_button = tk.Button(self.frame, text='next genic')
        self.next_genic_button.bind('<ButtonPress-1>', self.next_genic)
        self.next_genic_button.grid(row=0, column=2)

        self.seq_index_label = tk.Label(self.frame)
        self.seq_index_input = tk.Entry(self.frame, width=6)
        self.seq_index_button = tk.Button(self.frame, text='go')
        self.seq_index_button.bind('<ButtonPress-1>', self.go_seq_index)
        self.seq_index_random_button = tk.Button(self.frame, text='random')
        self.seq_index_random_button.bind('<ButtonPress-1>', self.go_seq_index_random)
        self.seq_index_random_genic_button = tk.Button(self.frame, text='random genic')
        self.seq_index_random_genic_button.bind('<ButtonPress-1>', self.go_seq_index_random_genic)
        self.seq_index_random_genic_in_genome_button = tk.Button(self.frame,
                                                                 text='random genic in genome')
        self.seq_index_random_genic_in_genome_button.bind('<ButtonPress-1>',
                                                          self.go_seq_index_random_genic_in_genome)
        self.seq_index_label.grid(row=1, column=0)
        self.seq_index_input.grid(row=1, column=1)
        self.seq_index_button.grid(row=1, column=2)
        self.seq_index_random_button.grid(row=1, column=3)
        self.seq_index_random_genic_button.grid(row=1, column=4)
        self.seq_index_random_genic_in_genome_button.grid(row=2, column=4)

        self.seq_offset_label = tk.Label(self.frame)
        self.seq_offset_input = tk.Entry(self.frame, width=6)
        self.seq_offset_button = tk.Button(self.frame, text='go')
        self.seq_offset_button.bind('<ButtonPress-1>', self.go_seq_offset)
        self.seq_offset_label.grid(row=2, column=0)
        self.seq_offset_input.grid(row=2, column=1)
        self.seq_offset_button.grid(row=2, column=2)

        self.species_var = tk.StringVar(self.frame)
        self.species_drop_down = tk.OptionMenu(self.frame, self.species_var, *self.all_species_names,
                                               command=self.go_species)
        self.seqid_jump_input = tk.Entry(self.frame, width=10)
        self.seqid_jump_button = tk.Button(self.frame, text='go')
        self.seqid_jump_button.bind('<ButtonPress-1>', self.go_seqid)
        self.species_drop_down.grid(row=1, column=7)
        self.seqid_jump_input.grid(row=2, column=7)
        self.seqid_jump_button.grid(row=2, column=8)

        self.seq_info_species = tk.Label(self.frame, padx=100)
        self.seq_info_seqid = tk.Label(self.frame)
        self.seq_info_start_end = tk.Label(self.frame)
        self.seq_info_species.grid(row=1, column=9)
        self.seq_info_seqid.grid(row=2, column=9)
        self.seq_info_start_end.grid(row=3, column=9)

        self.toggle_dna_state = tk.IntVar()
        self.toggle_dna_sequence = tk.Checkbutton(self.frame, text='show DNA', command=self.redraw,
                                                  variable=self.toggle_dna_state)
        self.toggle_dna_sequence.grid(row=1, column=10)

        self.error_label = tk.Label(self.frame)
        self.error_label.grid(row=4, column=1)

        # figure, canvas etc
        fig_main = Figure(figsize=(self.HEATMAP_SIZE_X / self.DPI, self.HEATMAP_SIZE_Y / self.DPI),
                     dpi=self.DPI)
        self.ax_main = fig_main.add_subplot(111)
        self.canvas_main = FigureCanvasTkAgg(fig_main, self.root)
        self.canvas_main.draw()
        self.canvas_main.get_tk_widget().pack(side=tk.TOP, fill=tk.BOTH, expand=True)

        fig_summary = Figure(figsize=(self.HEATMAP_SIZE_X / self.DPI,
                                      self.PIXEL_SIZE * self.label_dim / self.DPI),
                     dpi=self.DPI)
        self.ax_summary = fig_summary.add_subplot(111)
        self.canvas_summary = FigureCanvasTkAgg(fig_summary, self.root)
        self.canvas_summary.draw()
        self.canvas_summary.get_tk_widget().pack(side=tk.TOP, fill=tk.BOTH, expand=True)

        self.redraw(changed_seq=True)

    def load_sequence_infos(self):
        """parses the /data/species and /data/seqid datasets into a usable dict format"""
        def start_idx_dict(arr):
            data_raw, start_idx = np.unique(arr, return_index=True)
            data = [d.decode('utf-8') for d in data_raw]
            d = {d:i for d, i in zip(data, start_idx)}
            return d

        species_arr = np.array(self.h5_data['/data/species'])
        seqids_arr = np.array(self.h5_data['/data/seqids'])

        # construct species start dict
        self.species_start_idx = start_idx_dict(species_arr)
        self.all_species_names = list(self.species_start_idx.keys())

        # construct seqid dict
        self.seqids_start_idx = {}
        for species in self.all_species_names:
            species_idx = np.where(species_arr == species.encode())[0]
            self.seqids_start_idx[species] = start_idx_dict(seqids_arr[species_idx])

    def load_sequence(self, offset, seq_len, include_dummy=True):
        """loads data for the heatmap and possibly inputs dummy data that serves as margin"""
        def add_dummy_data(dset, new_dset):
            # insert valid data at every second row
            new_dset[0::2,:] = dset.reshape((self.args.n_rows, self.BASE_COUNT_X, self.label_dim))
            # reshape back to properly display in heatmap
            new_dset = np.swapaxes(new_dset, 1, 2)
            new_dset = new_dset.reshape((self.args.n_rows * 2) * self.label_dim, self.BASE_COUNT_X)
            return new_dset

        off_lim = offset + seq_len
        labels = np.array(self.h5_data['/data/y'][self.seq_index][offset:off_lim])
        predictions = np.array(self.h5_predictions['/predictions'][self.seq_index][offset:off_lim])
        label_masks = np.array(self.h5_data['/data/sample_weights'][self.seq_index][offset:off_lim])

        if off_lim > self.chunk_len - self.cutoff:
            # append 0-padding and set sample weights at the very end to make everything evenly long
            predictions = np.pad(predictions, ((0, self.cutoff), (0, 0)), constant_values=(0, 0))

        errors = np.abs(labels - predictions)
        label_masks = np.repeat(label_masks[:, np.newaxis], self.label_dim, axis=1)
        label_masks = ([1] - label_masks).astype(bool)

        if include_dummy:
            # reshape and add dummy data
            new_labels = np.zeros((self.args.n_rows * 2, self.BASE_COUNT_X, self.label_dim),
                                  dtype=labels.dtype)
            labels = add_dummy_data(labels, new_labels)
            new_errors = np.zeros((self.args.n_rows * 2, self.BASE_COUNT_X, self.label_dim),
                                  dtype=errors.dtype)
            errors = add_dummy_data(errors, new_errors)
            new_label_masks = np.ones((self.args.n_rows * 2,
                                       self.BASE_COUNT_X,
                                       self.label_dim)).astype(bool)
            label_masks = add_dummy_data(label_masks, new_label_masks)

        # make string annotations
        labels_str = labels.astype(str)
        labels_str[labels_str == '0'] = ''
        labels_str[labels_str == '1'] = '-'

        if include_dummy and self.toggle_dna_state.get():
            # add genic sequence to string annotations
            genic_seq = np.array(self.h5_data['/data/X'][self.seq_index][offset:off_lim])
            decode_dict = {tuple(a):c for c, a in AMBIGUITY_DECODE.items()}
            genic_seq = np.array([decode_dict[tuple(i)] for i in genic_seq])
            genic_seq = genic_seq.reshape((self.args.n_rows, self.BASE_COUNT_X))
            for i, n in enumerate(range(self.label_dim, labels.shape[0], self.label_dim * 2)):
                labels_str[n] = genic_seq[i]
                errors[n] = np.full((self.BASE_COUNT_X,), 0.5, dtype=errors.dtype)
                label_masks[n] = np.zeros((self.BASE_COUNT_X,), dtype=bool)

        return labels, errors, label_masks, labels_str

    def draw_main_heatmap(self):
        labels, errors, label_masks, labels_str = self.load_sequence(self.offset,
                                                                     self.BASE_COUNT_SCREEN,
                                                                     include_dummy=True)
        self.ax_main.clear()
        seaborn.heatmap(errors,
                        vmin=0 + args.colorbar_offset,
                        vmax=1 - args.colorbar_offset,
                        cmap='bwr',
                        center=0.5,
                        square=True,
                        cbar=False,
                        mask=label_masks,
                        annot=labels_str,
                        fmt='',
                        annot_kws={'fontweight': 'bold'},
                        # annot_kws={'fontsize': 8},
                        xticklabels=False,
                        yticklabels=False,
                        ax=self.ax_main)
        self.canvas_main.draw()

    def draw_summary_heatmap(self):
        _, errors, label_masks, label_str = self.load_sequence(0, self.chunk_len, include_dummy=False)

        labels = label_str == '-'  # convert to bool
        labels = np.swapaxes(labels, 0, 1)
        labels = labels.reshape((self.label_dim, 100, labels.shape[1] // 100))
        labels = labels.any(axis=2)
        labels_str = labels.astype(str)
        labels_str[labels_str == 'True'] = '-'
        labels_str[labels_str == 'False'] = ''

        masked_errors = np.ma.masked_array(errors, mask=label_masks)
        # reshape and average over each part
        masked_errors = np.swapaxes(masked_errors, 0, 1)
        masked_errors = masked_errors.reshape((self.label_dim, 100, self.chunk_len // 100))
        masked_errors_avg = np.mean(masked_errors, axis=2)

        # paint
        self.ax_summary.clear()
        seaborn.heatmap(masked_errors_avg,
                        vmin=0,
                        vmax=1,
                        cmap='bwr',
                        center=0.5,
                        square=True,
                        cbar=False,
                        mask=masked_errors_avg.mask,
                        annot=labels_str,
                        fmt='',
                        annot_kws={'fontweight': 'bold'},
                        xticklabels=False,
                        yticklabels=False,
                        ax=self.ax_summary)
        self.canvas_summary.draw()

    def update_widgets(self):
        # update text display
        species = self.h5_data['/data/species'][self.seq_index].decode('utf-8')
        seqid = self.h5_data['/data/seqids'][self.seq_index].decode('utf-8')
        start_end = list(self.h5_data['/data/start_ends'][self.seq_index])

        self.seq_info_species.config(text=species)
        self.seq_info_seqid.config(text=seqid)
        self.seq_info_start_end.config(text=str(start_end))

        self.species_var.set(species)
        self.seqid_jump_input.delete(0, 'end')
        self.seqid_jump_input.insert(0, seqid)

    def next(self, event):
        self.offset = (self.offset + self.BASE_COUNT_SCREEN) % self.chunk_len
        if self.offset < self.BASE_COUNT_SCREEN:
            self.load_seq_index(self.seq_index + 1)
        else:
            self.redraw(changed_seq=False)

    def previous(self, event):
        if self.offset < self.BASE_COUNT_SCREEN:
            self.offset = self.chunk_len + self.offset - self.BASE_COUNT_SCREEN
            self.load_seq_index(self.seq_index - 1, keep_offset=True)
        else:
            self.offset -= self.BASE_COUNT_SCREEN
            self.redraw(changed_seq=False)

    def next_genic(self, event):
        next_genic_index = np.searchsorted(self.genic_indexes, self.seq_index, side='right')
        self.load_seq_index(self.genic_indexes[next_genic_index])

    def go_species(self, event):
        self.load_seq_index(self.species_start_idx[self.species_var.get()])

    def go_seqid(self, event):
        seqid = self.seqid_jump_input.get().strip()
        species = self.species_var.get()
        if seqid in self.seqids_start_idx[species]:
            self.load_seq_index(self.seqids_start_idx[species][seqid])
        else:
            self.error_label.config(text='ERROR: Seqid not found for this species')

    def load_seq_index(self, new_seq_index, keep_offset=False):
        if new_seq_index <= self.n_seq:
            self.seq_index = new_seq_index
            if not keep_offset:
                self.offset = 0
            self.redraw(changed_seq=True)
            self.error_label.config(text='')
        else:
            self.error_label.config(text='ERROR: End of data reached')

        if self.args.exclude_errors and new_seq_index in self.err_idx:
            self.error_label.config(text='WARNING: Sequence has errors')

    def go_seq_index(self, event):
        new_seq_index = int(self.seq_index_input.get())
        self.load_seq_index(new_seq_index)

    def go_seq_index_random(self, event):
        if self.args.exclude_errors:
            clean_seq_indexes = np.delete(np.arange(self.n_seq), self.err_idx)
            random_seq_index = random.choice(clean_seq_indexes)
        else:
            random_seq_index = random.randint(0, self.n_seq)
        self.load_seq_index(random_seq_index)

    def go_seq_index_random_genic(self, event):
        random_genic_seq_index = np.random.choice(self.genic_indexes)
        self.load_seq_index(random_genic_seq_index)

    def go_seq_index_random_genic_in_genome(self, event):
        species_arr = np.array(self.h5_data['/data/species'])
        species_idx = np.where(species_arr == self.species_var.get().encode())[0]
        idx_pool = np.intersect1d(species_idx, self.genic_indexes)
        random_genic_seq_index = np.random.choice(idx_pool)
        self.load_seq_index(random_genic_seq_index)

    def go_seq_offset(self, event):
        """offset here is within a sequence, as it appears to the user"""
        new_seq_offset = int(self.seq_offset_input.get())
        if new_seq_offset <= self.chunk_len:
            self.offset = new_seq_offset
            self.redraw()

    def redraw(self, changed_seq=False):
        self.seq_offset_label.config(text=str('base: {}/{}'.format(self.offset, self.chunk_len - 1)))
        self.seq_index_label.config(text=str('seq: {}/{}'.format(self.seq_index, self.n_seq - 1)))
        self.draw_main_heatmap()
        if changed_seq:
            self.draw_summary_heatmap()
            self.update_widgets()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--test-data', type=str, default='', required=True)
    parser.add_argument('-p', '--predictions', type=str, default='', required=True)
    parser.add_argument('-r', '--n-rows', type=int, default=5)
    # how to narrow down the vmin/vmax args of the heatmap as predictions are very close to 0
    parser.add_argument('-cbo', '--colorbar-offset', type=float, default=0.0)
    parser.add_argument('-ee', '--exclude-errors', action='store_true')
    args = parser.parse_args()

    root = tk.Tk()
    root.title('Helixer Visualization')
    vis = Visualization(root, args)
    root.mainloop()
