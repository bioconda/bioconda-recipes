import argparse
import re
import sys
import time
from subprocess import PIPE, Popen

from pedesigner.needle import needle


def rev_comp(s):
    return s.translate(s.maketrans("ATGCRYSWKMBDHV", "TACGYRWSMKVHDB"))[::-1]


def rev_pos(rl, p):
    return rl - p - 1


def gc(s):
    return round((s.count("G") + s.count("C")) * 100 / len(s), 2)


class PeDesigner:
    def __init__(self, args):
        ref_file = args.ref_directory
        ind_file = args.ind_directory
        sref = open(ref_file).readlines()
        sind = open(ind_file).readlines()
        if sref[0][0] != ">" or sind[0][0] != ">":
            print("[Error] the file is not FASTA format !!")
            sys.exit()
        self.ref_seq = "".join(sref[1:]).replace("\n", "").upper()
        self.ind_seq = "".join(sind[1:]).replace("\n", "").upper()
        self.pam = args.pam.upper()
        self.ref_dir = args.ref_dir
        self.rna_len = args.l
        self.mm_num = args.m + 1
        self.pbs_min = args.pbs_min
        self.pbs_max = args.pbs_max
        self.rtt_min = args.rtt_min
        self.rtt_max = args.rtt_max
        self.nick_min = args.nick_min
        self.nick_max = args.nick_max
        self.use_cpus = args.use_cpus
        self.seq_list = []  # d -> [seq, info_l, pbs_d, rtt_d, nick_d]
        self.off_d = {}

        self.offinder_input = [self.ref_dir, "N" * self.rna_len + self.pam]

    def set_mutation(self):
        needle_res = needle(self.ref_seq, self.ind_seq, 10, -2, 10, -2)
        self.mutation_st = -1
        for n, sym in enumerate(needle_res[1]):
            if sym != "|":
                print(n)
                self.mutation_st = n
                break
        self.mutation_ed = -1
        for n, sym in enumerate(needle_res[1][::-1]):
            if sym != "|":
                self.mutation_ed = len(needle_res[1]) - n
                break
        if self.mutation_st == -1 or self.mutation_ed == -1:
            print("reference sequence and induced sequence is same!!!")
            sys.exit()
        self.mutation_len = self.mutation_ed - self.mutation_st - 1
        self.needle_res = needle_res

    def find_target(self):
        pattern = "N" * self.rna_len + self.pam
        pattern = "(" + pattern + ")"
        pattern = (
            pattern.replace("N", "[AGTC]")
            .replace("R", "[AG]")
            .replace("W", "[AT]")
            .replace("M", "[AC]")
            .replace("Y", "[CT]")
            .replace("S", "[GC]")
            .replace("K", "[GT]")
            .replace("B", "[CGT]")
            .replace("D", "[AGT]")
            .replace("H", "[ACT]")
            .replace("V", "[ACG]")
        )
        pattern = re.compile(pattern)
        pattern_r = "(" + rev_comp("N" * self.rna_len + self.pam) + ")"
        pattern_r = (
            pattern_r.replace("N", "[AGTC]")
            .replace("R", "[AG]")
            .replace("W", "[AT]")
            .replace("M", "[AC]")
            .replace("Y", "[CT]")
            .replace("S", "[GC]")
            .replace("K", "[GT]")
            .replace("B", "[CGT]")
            .replace("D", "[AGT]")
            .replace("H", "[ACT]")
            .replace("V", "[ACG]")
        )
        pattern_r = re.compile(pattern_r)
        pam_pattern = re.compile(
            self.pam.replace("N", "[AGTC]")
            .replace("R", "[AG]")
            .replace("W", "[AT]")
            .replace("M", "[AC]")
            .replace("Y", "[CT]")
            .replace("S", "[GC]")
            .replace("K", "[GT]")
            .replace("B", "[CGT]")
            .replace("D", "[AGT]")
            .replace("H", "[ACT]")
            .replace("V", "[ACG]")
        )

        pos = 0
        m = pattern.search(self.ref_seq, pos)
        targets = []
        while m != None:
            seq = m.group()
            pos = m.start()
            if m.group(1) != None:
                pbs_l = []
                rtt_l = []
                minlen_rtt = (
                    self.mutation_ed
                    + 1
                    - (pos + self.rna_len - 3 - 1)
                    - self.needle_res[2].count("-")
                )
                if (
                    minlen_rtt > self.rtt_max
                    or pos + self.rna_len - 3 - 1 > self.mutation_st
                ):
                    pos += 1
                    m = pattern.search(self.ref_seq, pos)
                    continue
                strand = "+"
                rel_pos = round((pos + (self.rna_len - 3)) * 100 / len(self.ref_seq), 2)
                edit_pos = self.mutation_st - (pos + 16)
                if (
                    pam_pattern.search(
                        self.ind_seq[
                            pos + self.rna_len : pos + self.rna_len + len(self.pam)
                        ]
                    )
                    != None
                ):
                    pam_change = "No"
                else:
                    pam_change = "Yes"
                for x in range(self.pbs_min, self.pbs_max + 1):
                    pbs_s = self.ref_seq[
                        pos + self.rna_len - 3 - x : pos + self.rna_len - 3
                    ]
                    pbs_l.append([pbs_s, x, gc(pbs_s)])
                for x in range(self.rtt_min, self.rtt_max + 1):
                    if minlen_rtt > x:
                        continue
                    rtt_s = self.ind_seq[
                        pos + self.rna_len - 3 : pos + self.rna_len - 3 + x
                    ]
                    rtt_l.append([rtt_s, x, gc(rtt_s)])

                off_s = (
                    seq[: self.rna_len]
                    + "N" * len(self.pam)
                    + " "
                    + str(self.mm_num - 1)
                )
                if off_s not in self.offinder_input:
                    self.offinder_input.append(off_s)
                    self.off_d[seq[: self.rna_len]] = []
                    for x in range(self.mm_num):
                        self.off_d[seq[: self.rna_len]].append(0)

                sub_res = [
                    seq,
                    [
                        pos + 1,
                        rel_pos,
                        strand,
                        gc(seq[: self.rna_len]),
                        edit_pos,
                        pam_change,
                    ],
                    pbs_l,
                    rtt_l,
                    [],
                ]

                self.seq_list.append(sub_res)
            pos += 1
            m = pattern.search(self.ref_seq, pos)

        pos = 0
        m = pattern_r.search(self.ref_seq, pos)
        while m != None:
            seq = m.group()
            pos = m.start()
            if m.group(1) != None:
                seq = rev_comp(seq)
                pbs_l = []
                rtt_l = []
                rp = rev_pos(
                    len(self.ref_seq), (pos + self.rna_len + len(self.pam) - 1)
                )
                minlen_rtt = (
                    rev_pos(len(self.needle_res[0]), self.mutation_st - 1)
                    - (rp + self.rna_len - 3 - 1)
                    - self.needle_res[2].count("-")
                )
                if (
                    rev_pos(len(self.needle_res[0]), self.mutation_ed)
                    < rp + self.rna_len - 3 - 1
                    or minlen_rtt > self.rtt_max
                ):
                    pos += 1
                    m = pattern_r.search(self.ref_seq, pos)
                    continue
                strand = "-"
                rel_pos = round(
                    (pos + (3 + len(self.pam))) * 100 / len(self.ref_seq), 2
                )
                edit_pos = (
                    pos + self.needle_res[0].count("-") + 6 - self.mutation_ed + 1
                )
                if (
                    pam_pattern.search(
                        rev_comp(self.ind_seq)[
                            rp - self.rna_len - len(self.pam) : rp - self.rna_len
                        ]
                    )
                    != None
                ):
                    pam_change = "No"
                else:
                    pam_change = "Yes"
                for x in range(self.pbs_min, self.pbs_max + 1):
                    pbs_s = self.ref_seq[
                        pos + len(self.pam) + 3 : pos + len(self.pam) + 3 + x
                    ]
                    pbs_l.append([pbs_s, x, gc(pbs_s)])
                for x in range(self.rtt_min, self.rtt_max + 1):
                    if minlen_rtt > x:
                        continue
                    rtt_s = rev_comp(
                        rev_comp(self.ind_seq)[
                            rp + self.rna_len - 3 : rp + self.rna_len - 3 + x
                        ]
                    )
                    rtt_l.append([rtt_s, x, gc(rtt_s)])

                off_s = (
                    seq[: self.rna_len]
                    + "N" * len(self.pam)
                    + " "
                    + str(self.mm_num - 1)
                )
                if off_s not in self.offinder_input:
                    self.offinder_input.append(off_s)
                    self.off_d[seq[: self.rna_len]] = []
                    for x in range(self.mm_num):
                        self.off_d[seq[: self.rna_len]].append(0)

                sub_res = [
                    seq,
                    [
                        pos + 1,
                        rel_pos,
                        strand,
                        gc(seq[: self.rna_len]),
                        edit_pos,
                        pam_change,
                    ],
                    pbs_l,
                    rtt_l,
                    [],
                ]

                self.seq_list.append(sub_res)

            pos += 1
            m = pattern_r.search(self.ref_seq, pos)

        pos = 0
        m = pattern.search(self.ind_seq, pos)
        while m != None:
            seq = m.group()
            pos = m.start()
            selected = False
            PE_type = "PE3"
            if (
                pos + self.needle_res[2].count("-") < self.mutation_ed
                and pos + self.rna_len + len(self.pam) > self.mutation_st
            ):
                PE_type = "PE3b"
            if m.group(1) != None:
                rel_pos = round(
                    (pos + self.rna_len - 3 - 1) * 100 / len(self.ind_seq), 2
                )
                for i in range(len(self.seq_list)):
                    line = self.seq_list[i]
                    if line[1][2] != "-":
                        continue
                    cv = (
                        line[1][0]
                        + len(self.pam)
                        + 3
                        - 1
                        + self.needle_res[0].count("-")
                        - self.needle_res[2].count("-")
                    )
                    distance = (pos + self.rna_len - 3) - cv
                    if distance == 0:
                        distance += 1
                    if self.nick_min <= abs(distance) <= self.nick_max:
                        sub_nick = [
                            seq,
                            pos + 1,
                            rel_pos,
                            "+",
                            gc(seq[: self.rna_len]),
                            distance,
                            PE_type,
                        ]
                        for x in range(self.mm_num):
                            sub_nick.append(0)
                        self.seq_list[i][4].append(sub_nick)
                        selected = True

            if selected == True:
                off_s = (
                    seq[: self.rna_len]
                    + "N" * len(self.pam)
                    + " "
                    + str(self.mm_num - 1)
                )
                if off_s not in self.offinder_input:
                    self.offinder_input.append(off_s)
                    self.off_d[seq[: self.rna_len]] = []
                    for x in range(self.mm_num):
                        self.off_d[seq[: self.rna_len]].append(0)

            pos += 1
            m = pattern.search(self.ind_seq, pos)

        pos = 0
        m = pattern_r.search(self.ind_seq, pos)
        while m != None:
            seq = m.group()
            pos = m.start()
            selected = False
            PE_type = "PE3"
            if (
                pos + self.needle_res[2].count("-") < self.mutation_ed
                and pos + self.rna_len + len(self.pam) > self.mutation_st
            ):
                PE_type = "PE3b"
            if m.group(1) != None:
                rel_pos = round(
                    (pos + self.rna_len + len(self.pam) + 3) * 100 / len(self.ind_seq),
                    2,
                )
                seq = rev_comp(seq)
                for i in range(len(self.seq_list)):
                    line = self.seq_list[i]
                    if line[1][2] != "+":
                        continue
                    cv = line[1][0] + self.rna_len - 3
                    distance = (pos + len(self.pam) + 3 + 1) - cv
                    if distance == 0:
                        distance -= 1
                    if self.nick_min <= abs(distance) <= self.nick_max:
                        sub_nick = [
                            seq,
                            pos + 1,
                            rel_pos,
                            "-",
                            gc(seq[len(self.pam) :]),
                            distance,
                            PE_type,
                        ]
                        for x in range(self.mm_num):
                            sub_nick.append(0)
                        self.seq_list[i][4].append(sub_nick)
                        selected = True

            if selected == True:
                off_s = (
                    seq[: self.rna_len]
                    + "N" * len(self.pam)
                    + " "
                    + str(self.mm_num - 1)
                )
                if off_s not in self.offinder_input:
                    self.offinder_input.append(off_s)
                    self.off_d[seq[: self.rna_len]] = []
                    for x in range(self.mm_num):
                        self.off_d[seq[: self.rna_len]].append(0)

            pos += 1
            m = pattern_r.search(self.ind_seq, pos)

    def run_cas_offinder(self):

        with open("cas-offinder-input.txt", "w") as fw:
            fw.write("\n".join(self.offinder_input))
        if self.use_cpus:
            proc = Popen(
                [
                    "cas-offinder",
                    "cas-offinder-input.txt",
                    "C",
                    "cas-offinder-output.txt",
                ],
                stdout=PIPE,
            ).communicate()
        else:
            proc = Popen(
                [
                    "cas-offinder",
                    "cas-offinder-input.txt",
                    "G",
                    "cas-offinder-output.txt",
                ],
                stdout=PIPE,
            ).communicate()

        with open("cas-offinder-output.txt") as f:
            for line in f:
                line_sp = line.strip().split("\t")
                self.off_d[line_sp[0][: self.rna_len]][int(line_sp[5])] += 1
        print(self.off_d)

    def write_result(self):

        multiply = 7 + self.mm_num
        menu = [
            "Target Sequence (5' to 3')",
            "Position",
            "Cleavage Position (%)",
            "Direction",
            "GC Content",
            "Edit Position",
            "PAM Change",
        ]
        for i in range(self.mm_num):
            menu.append("Mismatch {0}".format(i))
        menu += [
            "Type",
            "Extension Sequence",
            "PBS length",
            "PBS GC Content",
            "RTT length",
            "RTT GC Content",
            "Target Sequence (5' to 3')",
            "Position",
            "Cleavage Position (%)",
            "Direction",
            "GC Content",
            "Distance",
            "PE Type",
        ]
        for i in range(self.mm_num):
            menu.append("Mimatch {0}".format(i))

        with open("result.txt", "w") as fw:
            fw.write("\t".join(menu) + "\n")
            for i in self.seq_list:
                mm = self.off_d[i[0][: self.rna_len]]
                main_str = i[0] + "\t"
                for x in i[1]:
                    main_str += str(x) + "\t"
                for x in mm:
                    main_str += str(x) + "\t"
                for x in i[2]:
                    for y in i[3]:
                        if i[1][2] == "+":
                            s = (
                                main_str
                                + "pegRNA\t"
                                + rev_comp(x[0] + " " + y[0])
                                + "\t"
                                + str(x[1])
                                + "\t"
                                + str(x[2])
                                + "\t"
                                + str(y[1])
                                + "\t"
                                + str(y[2])
                                + "\t"
                                + "-\t" * multiply
                            )
                            fw.write(s[:-1] + "\n")
                        if i[1][2] == "-":
                            s = (
                                main_str
                                + "pegRNA\t"
                                + y[0]
                                + " "
                                + x[0]
                                + "\t"
                                + str(x[1])
                                + "\t"
                                + str(x[2])
                                + "\t"
                                + str(y[1])
                                + "\t"
                                + str(y[2])
                                + "\t"
                                + "-\t" * multiply
                            )
                            fw.write(s[:-1] + "\n")
                for x in i[4]:
                    mm_nick = self.off_d[x[0][: self.rna_len]]
                    s = (
                        main_str
                        + "nCas9\t"
                        + "-\t" * 5
                        + x[0]
                        + "\t"
                        + str(x[1])
                        + "\t"
                        + str(x[2])
                        + "\t"
                        + str(x[3])
                        + "\t"
                        + str(x[4])
                        + "\t"
                        + str(x[5])
                        + "\t"
                        + str(x[6])
                        + "\t"
                    )
                    for y in mm_nick:
                        s += str(y) + "\t"
                    fw.write(s[:-1] + "\n")


def parse_args():

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "ref_directory",
        type=str,
        help="Path of reference sequence file in FASTA format",
    )
    parser.add_argument(
        "ind_directory",
        type=str,
        help="Path of reference sequence file in FASTA format",
    )
    parser.add_argument("pam", type=str, help="PAM sequence")
    parser.add_argument(
        "ref_dir",
        type=str,
        help="Directory of reference genome file, in FASTA or 2bit format",
    )
    parser.add_argument("-l", type=int, help="length of target without PAM", default=20)
    parser.add_argument("-m", type=int, help="Mismatch number", default=2)
    parser.add_argument("--pbs_min", type=int, help="Minimum of PBS length", default=12)
    parser.add_argument("--pbs_max", type=int, help="Maximum of PBS length", default=14)
    parser.add_argument("--rtt_min", type=int, help="Minimum of RTT length", default=10)
    parser.add_argument("--rtt_max", type=int, help="Maximum of RTT length", default=20)
    parser.add_argument(
        "--nick_min", type=int, help="Minimum of nicking distance", default=0
    )
    parser.add_argument(
        "--nick_max", type=int, help="Maximum of nicking distance", default=100
    )
    parser.add_argument(
        "--use_cpus",
        action="store_true",
        help="Use cpu instead of gpu (cas-offinder)",
        required=False,
    )

    return parser.parse_args()


def main():
    tst = time.time()
    args = parse_args()

    c = PeDesigner(args)

    c.set_mutation()
    print("find target...")
    c.find_target()
    print("find off-target...")
    c.run_cas_offinder()
    print("writing results...")
    c.write_result()
    print("finish!")


if __name__ == "__main__":
    main()
