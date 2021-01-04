import global_values
import pysam
#this module is designed to call internal mutations from alignments (either short or long reads)
#this is a stand alone module
#different from x_mutation.py: x_mutation.py is maily designed for 10X data

class InternalMutation():
    #copied from x_ref_rep_copy.py in xTEA_source_tracing
    ####Call out the snp from repeat copy alignments: From the MD field
    # The bam file is process by "samtools calmd -e " first.
    def call_snp_indel_from_algnmt(self, sf_sam, sf_ref, bmapped_cutoff, sf_mutation):
        bamfile = pysam.AlignmentFile(sf_sam, "r", reference_filename=sf_ref)
        with open(sf_mutation, "w") as fout_mutation:
            for algnmt in bamfile.fetch():
                if algnmt.has_tag("MD") == False:
                    continue
                if algnmt.is_unmapped == True:  ####skip the unmapped reads
                    continue
                l_cigar = algnmt.cigar
                b_clip_qualified_algned, n_map_bases = self._is_clipped_part_qualified_algnmt(l_cigar, bmapped_cutoff)
                if b_clip_qualified_algned == False:  # skip the unqualified re-aligned parts
                    continue

                qname = algnmt.query_name
                map_pos = algnmt.reference_start
                q_seq = algnmt.query_sequence
                s_md = algnmt.get_tag("MD")
                l_cigar = algnmt.cigar

                m_mut = self.call_snp_indel(l_cigar, map_pos, s_md, q_seq)
                for mut_type in m_mut:
                    for tmp_pos in m_mut[mut_type]:
                        c_r=m_mut[mut_type][tmp_pos][0]
                        c_q=m_mut[mut_type][tmp_pos][1]
                        fout_mutation.write(qname+"\t"+str(tmp_pos)+"\t"+c_r+"\t"+c_q+"\n")
        bamfile.close()
####

    ####
    # Input:
    # 1. l_cigar is a list of cigar strs. 0-M, 1-I, 2-D, 4-S, 5-H, e.g. [(0, 72), (1, 1), (0, 602), (2, 4), (0, 2301), (2, 1), (0, 3053)],
    # 2. s_md is the MD field.
    # In MD field, ^ indicates the start of deletion.
    # e.g. 1G58G98C70T22T97G25G104G67C123^CAGA29T63G80G145G198G38C87T139T69C125T154T146T6A405C188C45G105C262^C350T100C10T510C152A17C82C43G14G0T288T154T5A2T176A107A86C66T230C116C26T2G173A52C65A99A102

    # 3. q_seq is the query seq #this is processed by "samtools calcmd -e". Insertion is showed in seq, but deletion is not.
    # 4. r_seq is the reference seq #this is the original "ref consensus" seq
    # all the postion will be re-calc based on the position on the original ref
    def call_snp_indel(self, l_cigar, ref_start, s_md, q_seq):
        m_mut = {}
        m_mut["M"] = {}  # mismatch
        m_mut["I"] = {}  # insertion
        m_mut["D"] = {}  # deletion

        # parse out deletions and mismatches by order
        l_del, l_mismatch_query = self.call_mismatch_del_from_md(s_md)

        idx_mismatch = 0  # index for l_mismatch_query which save all the mismatches
        idx_del = 0  # index for l_del which save all the mismatches
        ref_pos = ref_start  # global coordinate on the ref, start from 0

        q_start = 0
        q_end = 0
        for (itype, ilen) in l_cigar:
            if itype == 0:  # match or mismatch
                # get the query segment
                q_start = q_end
                q_end += ilen
                s_tmp_q = q_seq[q_start:q_end]

                l_tmp_mismatch, idx_mismatch = self.parse_mismatch(s_tmp_q, l_mismatch_query, idx_mismatch, ref_pos)

                # save the mismatch to dict
                for (ipos, c_r, c_q) in l_tmp_mismatch:
                    m_mut["M"][ipos] = (c_r, c_q)
                ref_pos += ilen
            elif itype == 1:  # insertion
                q_start = q_end
                q_end += ilen
                s_tmp_q = q_seq[q_start:q_end]
                m_mut["I"][ref_pos] = (".", s_tmp_q)
            elif itype == 2:  # deletion
                m_mut["D"][ref_pos] = (l_del[idx_del], ".")
                idx_del += 1
                ref_pos += ilen
            elif itype == 4 or itype == 5:  # soft or hard clip
                q_start = q_end
                q_end += ilen
                ref_pos += ilen
            else:
                print("Cigar contains unprocessed type!", l_cigar)
        return m_mut

    ####parse out the mismatch for a given region
    def parse_mismatch(self, q_seq, l_mismatch_query, idx_mismatch, ref_pos):
        l_mismatch = []
        istart = ref_pos
        for idx, val in enumerate(q_seq):
            if val == "=":
                istart += 1
                continue
            else:
                istart += 1
                l_mismatch.append((istart, l_mismatch_query[idx_mismatch], q_seq[idx]))  # save the mismatch pair
                idx_mismatch += 1
        return l_mismatch, idx_mismatch

    ####
    ####
    def call_mismatch_del_from_md(self, s_md):
        l_del = []
        l_mismatch = []
        b_on = False
        s_del = ""
        for s in s_md:
            if s == '^':
                b_on = True
                continue
            if b_on == True:
                if s >= 'A' and s <= 'Z':
                    s_del += s
                else:
                    l_del.append(s_del)
                    b_on = False
                    s_del = ""
            else:
                if s >= 'A' and s <= 'Z':
                    l_mismatch.append(s)

        # for the last one if possible
        if s_del != "":
            l_del.append(s_del)
        return l_del, l_mismatch

    #####same function copied from x_clip_disc_filter.py
    def _is_clipped_part_qualified_algnmt(self, l_cigar, ratio_cutoff):
        if len(l_cigar) < 1:  # wrong alignment
            return False, 0
        if len(l_cigar) > 2:
            ####check the cigar
            ###if both clipped, and the clipped part is large, then skip
            b_left_clip = False
            i_left_clip_len = 0
            if l_cigar[0][0] == 4 or l_cigar[0][0] == 5:  # left clipped
                b_left_clip = True
                i_left_clip_len = l_cigar[0][1]
            b_right_clip = False
            i_right_clip_len = 0
            if l_cigar[-1][0] == 4 or l_cigar[-1][0] == 5:  # right clipped
                b_right_clip = True
                i_right_clip_len = l_cigar[-1][1]

            if b_left_clip == True and b_right_clip == True:
                if (i_left_clip_len > global_values.MAX_CLIP_CLIP_LEN) and (
                    i_right_clip_len > global_values.MAX_CLIP_CLIP_LEN):
                    return False, 0

        ####for the alignment (of the clipped read), if the mapped part is smaller than the clipped part,
        ####then skip
        n_total = 0
        n_map = 0
        for (type, lenth) in l_cigar:
            if type == 0:
                n_map += lenth
            if type != 2:  # deletion is not added to the total length
                n_total += lenth

        if n_map < (
            n_total * ratio_cutoff):  ########################require at least 3/4 of the seq is mapped !!!!!!!!
            return False, 0
        return True, n_map
####