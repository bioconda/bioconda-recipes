####
class XIGV():
####
    #in this version, each sample may have several related bams
    #each line in sf_bams is: sample-id xxx1.bam xxx2.bam
    def prepare_igv_scripts_multi_bams(self, sf_sites, sf_bams, s_wfolder, i_extnd, sf_gnm, sf_out):
        m_bams = {}
        with open(sf_bams) as fin_bams:
            for line in fin_bams:
                fields = line.split()
                if len(fields) < 2:
                    print(("Wrong bam file list ", line))
                    continue
                l_sf_bams=[]
                for sf_tmp_bam in fields[1:]:
                    l_sf_bams.append(sf_tmp_bam)
                m_bams[fields[0]] = l_sf_bams
        with open(sf_sites) as fin_sites, open(sf_out, "w") as fout:
            m_sites = {}
            for line in fin_sites:
                fields = line.split()
                if len(fields) < 3:
                    print(("Wrong site ", line))
                    continue
                s_id = fields[0]
                ins_chrm = fields[1]
                ins_pos = int(fields[2])
                s_region = "{0}:{1}-{2}".format(ins_chrm, ins_pos - i_extnd, ins_pos + i_extnd)
                s_region_id = "{0}_{1}_{2}_{3}".format(ins_chrm, ins_pos, ins_pos - i_extnd, ins_pos + i_extnd)
                if s_id not in m_sites:
                    m_sites[s_id] = []
                m_sites[s_id].append((s_region, s_region_id))

            for s_id in m_sites:
                if s_id not in m_bams:
                    print((s_id, "not in provided bam list!"))
                    continue
                l_sf_bam = m_bams[s_id]
                s_out_folder = s_wfolder
                self._new_bams_cmd_to_file(fout, l_sf_bam, sf_gnm, s_out_folder)
                for (s_region, s_region_id) in m_sites[s_id]:
                    s_screenshot_id = "{0}.{1}.png".format(s_id, s_region_id)
                    self._new_site_cmd_to_file(fout, s_region, s_screenshot_id)
####
    def gnrt_sites_single_sample(self, sf_sites, sf_bams):
        s_id="null"
        with open(sf_bams) as fin_bams:
            for line in fin_bams:
                fields=line.split()
                s_id=fields[0]
        sf_new_sites=sf_sites+".igv_sites"
        with open(sf_sites) as fin_sites, open(sf_new_sites,"w") as fout_new:
            for line in fin_sites:
                fout_new.write(s_id+"\t"+line)
        return sf_new_sites
    #
    def _new_bams_cmd_to_file(self, fout, l_sf_bam, sf_gnm, s_folder):
        fout.write("new\n")
        fout.write("genome {0}\n".format(sf_gnm))
        for sf_bam in l_sf_bam:
            fout.write("load {0}\n".format(sf_bam))
        fout.write("snapshotDirectory {0}\n".format(s_folder))
####
    def _new_bam_cmd_to_file(self, fout, sf_bam, sf_gnm, s_folder):
        fout.write("new\n")
        fout.write("genome {0}\n".format(sf_gnm))
        fout.write("load {0}\n".format(sf_bam))
        fout.write("snapshotDirectory {0}\n".format(s_folder))

    def _new_site_cmd_to_file(self, fout, s_region, s_name):
        fout.write("goto {0}\n".format(s_region))
        fout.write("sort position\n")
        fout.write("collapse\n")
        fout.write("snapshot {0}\n".format(s_name))

    #this is for one bam version
    def prepare_igv_scripts(self, sf_sites, sf_bams, s_wfolder, i_extnd, sf_gnm, sf_out):
        m_bams = {}
        with open(sf_bams) as fin_bams:
            for line in fin_bams:
                fields = line.split()
                if len(fields) < 2:
                    print(("Wrong bam file list ", line))
                    continue
                m_bams[fields[0]] = fields[1]
        with open(sf_sites) as fin_sites, open(sf_out, "w") as fout:
            m_sites = {}
            for line in fin_sites:
                fields = line.split()
                if len(fields) < 3:
                    print(("Wrong site ", line))
                    continue
                s_id = fields[0]
                ins_chrm = fields[1]
                ins_pos = int(fields[2])
                s_region = "{0}:{1}-{2}".format(ins_chrm, ins_pos - i_extnd, ins_pos + i_extnd)
                s_region_id = "{0}_{1}_{2}".format(ins_chrm, ins_pos - i_extnd, ins_pos + i_extnd)
                if s_id not in m_sites:
                    m_sites[s_id] = []
                m_sites[s_id].append((s_region, s_region_id))

            for s_id in m_sites:
                if s_id not in m_bams:
                    print((s_id, "not in provided bam list!"))
                    continue
                sf_bam = m_bams[s_id]
                s_out_folder = s_wfolder
                self._new_bam_cmd_to_file(fout, sf_bam, sf_gnm, s_out_folder)
                for (s_region, s_region_id) in m_sites[s_id]:
                    s_screenshot_id = "{0}.{1}.png".format(s_id, s_region_id)
                    self._new_site_cmd_to_file(fout, s_region, s_screenshot_id)

####