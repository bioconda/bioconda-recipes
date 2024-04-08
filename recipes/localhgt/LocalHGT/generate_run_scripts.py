#!/usr/bin/env python3

from simulation import Parameters
import re
import os

class Batch(Parameters):

    def __init__(self, reference):
        Parameters.__init__(self, reference)
        self.batch_num = 1
        self.workdir = "/mnt/d/breakpoints/HGT/"
        self.fq_dir = ''
        self.result_dir = ''
        self.localHGT = "/mnt/d/breakpoints/script/scripts/pipeline.sh"
        self.localHGT_main = "/mnt/d/breakpoints/script/scripts/main.py"
        self.hit = 0.1
        self.perfect_hit = 0.08
        self.fq1 = ''
        self.fq2 = ''
        self.sample_fasta = ''
        self.LEMON = "/mnt/d/breakpoints/lemon/pipeline.sh"
        self.lemon_outdir = "/mnt/e/HGT/lemon_snp/"

    def change_lemon_dir(self, my_dir):
        self.lemon_outdir = my_dir

    def get_fq_dir(self, fq_dir):
        self.fq_dir = fq_dir

    def get_result_dir(self, result_dir):
        self.result_dir = result_dir

    def get_fq(self):
        self.fq1 = self.fq_dir + '/%s.1.fq'%(self.sample)
        self.fq2 = self.fq_dir + '/%s.2.fq'%(self.sample)

    def get_minor_order(self):
        order = "/usr/bin/time -v -o %s/%s.time bash %s %s/%s.fa %s %s %s %s %s %s"%(self.result_dir, \
        self.sample, self.localHGT, self.fq_dir, self.sample, \
        self.fq1, self.fq2, self.sample, self.result_dir, self.hit, self.perfect_hit)
        return order

    def get_normal_order(self):
        order = "/usr/bin/time -v -o %s/%s.time bash %s %s %s %s %s %s %s %s"%(self.result_dir, self.sample,\
         self.localHGT, self.origin_ref, \
        self.fq1, self.fq2, self.sample, self.result_dir, self.hit, self.perfect_hit)
        return order 

    def get_new_order(self):
        order = "/usr/bin/time -v -o %s/%s.time bash %s %s %s %s %s %s %s %s 32 5"%(self.result_dir, self.sample,\
         self.localHGT, self.origin_ref, \
        self.fq1, self.fq2, self.sample, self.result_dir, self.hit, self.perfect_hit)
        return order 

    def get_main_order(self):
        order = f"/usr/bin/time -v -o {self.result_dir}/{self.sample}.time python {self.localHGT_main} \
        -r {self.origin_ref} -s {self.sample} -o {self.result_dir} --fq1 {self.fq1} --fq2 {self.fq2} --max_peak 600000000"
        return order 

    def get_lemon_order(self):
        order = f"/usr/bin/time -v -o {self.lemon_outdir}/{self.sample}.time bash {self.LEMON} {self.origin_ref}\
         {self.fq1} {self.fq2} {self.sample} {self.lemon_outdir}"
        return order

    def change_ID(self, new_id):
        self.sample = new_id

    def change_ref(self):
        self.origin_ref = self.fq_dir + f"{self.sample}.fa"

def batch_snp():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/uhgg_snp/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/uhgg_snp_results/")

    o = open(ba.workdir + 'work.sh', 'w')
    for h in range(ba.batch_num):
        f = open(ba.workdir +'work_%s.sh'%(h), 'w')
        f.close()
        print ('nohup sh %s/work_%s.sh &>%s/log%s&'%(ba.workdir, h, ba.workdir, h), file = o)

    i = 1
    index = 0
    for snp_rate in ba.snp_level:
    # for snp_rate in [0.08, 0.09]:
        ba.change_snp_rate(snp_rate)
        for index in range(ba.iteration_times):
            ba.get_ID(index)
            ba.get_fq()
            order = ba.get_minor_order()
            f = open('%s/work_%s.sh'%(ba.workdir, i%(ba.batch_num)), 'a')
            print (order, file = f)
            f.close()
            i += 1

def batch_cami():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/uhgg_snp/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/uhgg_snp_results/")

    f = open("/mnt/d/breakpoints/lemon/run_lemon_cami.sh", 'w')
    h = open("/mnt/d/breakpoints/HGT/run_localHGT_cami.sh", 'w')

    i = 1
    index = 0
    # for snp_rate in [0.09, 0.07, 0.05, 0.03, 0.01]:
    for snp_rate in [0.01, 0.02, 0.03, 0.04, 0.05]:
        ba.change_snp_rate(snp_rate)
        index = 0
        ba.get_ID(index)
        for level in ba.complexity_level:
            cami_ID = ba.sample + '_' + level
            ba.change_ID(cami_ID)
            ba.get_fq()
            order = ba.get_lemon_order()
            print (order, file = f)
            order = ba.get_normal_order()
            print (order, file = h)
            ba.get_ID(index) # refresh ID

    f.close()
    h.close()

def batch_pro_cami():
    ba = Batch(progenomes)
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/pro_snp/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/pro_snp_results/")
    ba.origin_ref = "/mnt/d/breakpoints/HGT/proGenomes/proGenomes_v2.1.fasta"

    f = open("/mnt/d/breakpoints/lemon/run_lemon_cami_pro.sh", 'w')
    h = open("/mnt/d/breakpoints/HGT/run_localHGT_cami_pro.sh", 'w')

    i = 1
    index = 0
    # for snp_rate in [0.09, 0.07, 0.05, 0.03, 0.01]:
    for snp_rate in [0.01, 0.02, 0.03, 0.04, 0.05]:
        ba.change_snp_rate(snp_rate)
        index = 0
        ba.get_ID(index)
        for level in ba.complexity_level:
            cami_ID = ba.sample + '_' + level
            ba.change_ID(cami_ID)
            ba.get_fq()
            order = ba.get_lemon_order()
            print (order, file = f)
            # order = ba.get_normal_order()
            order = ba.get_main_order()
            print (order, file = h)
            ba.get_ID(index) # refresh ID

    f.close()
    h.close()

def batch_depth():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/uhgg_depth/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/uhgg_depth_results/")
    ba.change_lemon_dir("/mnt/e/HGT/lemon_depth/")

    f = open("/mnt/d/breakpoints/lemon/run_lemon_depth.sh", 'w')
    h = open("/mnt/d/breakpoints/HGT/run_localHGT_depth.sh", 'w')

    i = 1
    index = 0

    for depth in [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]:
        ba.change_depth(depth)
        for index in range(10):
            ba.get_ID(index)
            ba.get_fq()
            ba.change_ref()
            order = ba.get_lemon_order()
            print (order, file = f)
            order = ba.get_normal_order()
            print (order, file = h)
            ba.get_ID(index) # refresh ID

    f.close()
    h.close()

def batch_snp_pure():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/uhgg_snp/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/uhgg_snp_pure/")
    ba.change_lemon_dir("/mnt/e/HGT/lemon_snp_pure/")

    f = open("/mnt/d/breakpoints/lemon/run_lemon_snp_pure.sh", 'w')
    h = open("/mnt/d/breakpoints/HGT/run_localHGT_snp_pure.sh", 'w')

    index = 0
    for snp_rate in [0.01, 0.02, 0.03, 0.04, 0.05]:
        ba.snp_rate = snp_rate 
        for index in range(10):
            ba.get_ID(index)
            ba.get_fq()
            ba.change_ref()
            order = ba.get_lemon_order()
            print (order, file = f)
            order = ba.get_normal_order()
            print (order, file = h)
            ba.get_ID(index) # refresh ID

    f.close()
    h.close()

def batch_length_pure():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/uhgg_length/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/uhgg_length_results/")
    ba.change_lemon_dir("/mnt/e/HGT/lemon_length_results/")

    f = open("/mnt/d/breakpoints/lemon/run_lemon_length.sh", 'w')
    h = open("/mnt/d/breakpoints/HGT/run_localHGT_length.sh", 'w')

    index = 0
    # for snp_rate in [0.01, 0.02, 0.03, 0.04, 0.05]:
    #     ba.snp_rate = snp_rate 
    for read_length in [100, 125]:
        ba.reads_len = read_length
        for index in range(10):
            ba.get_ID(index)
            ba.get_fq()
            ba.change_ref()
            order = ba.get_lemon_order()
            print (order, file = f)
            order = ba.get_normal_order()
            print (order, file = h)
            ba.get_ID(index) # refresh ID

    f.close()
    h.close()

def batch_france():
    ba = Batch()
    ba.get_fq_dir("//mnt/crc/PRJEB6070_crc_france/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/CRC/france/result")

    h = open("/mnt/d/breakpoints/HGT/CRC/france/run_localHGT_crc.sh", 'w')

    i = 1
    index = 0
    for line in open("/mnt/d/breakpoints/HGT/CRC/france/france_fq.list"):
        match = re.search("_crc_france/(.*?).1.fq.gz$", line)
        if match:
            ba.sample = match.group(1)
            ba.fq1 = "/mnt/crc/PRJEB6070_crc_france/%s.1.fq"%(ba.sample)
            ba.fq2 = "/mnt/crc/PRJEB6070_crc_france/%s.2.fq"%(ba.sample)
            print ("gzip -d /mnt/crc/PRJEB6070_crc_france/%s.*.fq.gz"%(ba.sample), file = h)
            order = ba.get_normal_order()
            print (order, file = h)
            print ("gzip /mnt/crc/PRJEB6070_crc_france/%s.*.fq"%(ba.sample), file = h)
    h.close()

def batch_germany():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/CRC/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/CRC/germany/result")

    h = open("/mnt/d/breakpoints/HGT/CRC/germany/run_localHGT_germany.sh", 'w')

    i = 1
    index = 0
    for line in open("/mnt/d/breakpoints/HGT/CRC/germany.csv"):
        array = line.split(",")
        if array[0] == "Run":
            continue
        else:
            ba.sample = array[0]
            ba.fq1 = "/mnt/d/breakpoints/HGT/CRC/germany/%s_1.fastq.gz"%(ba.sample)
            ba.fq2 = "/mnt/d/breakpoints/HGT/CRC/germany/%s_2.fastq.gz"%(ba.sample)
            order = ba.get_normal_order()
            if not os.path.isfile("/mnt/d/breakpoints/HGT/CRC/germany/result/%s.repeat.acc.csv"%(ba.sample)):
                if os.path.isfile("/mnt/d/breakpoints/HGT/CRC/germany/result/%s.acc.csv"%(ba.sample)):
                    if os.path.isfile(ba.fq1):
                        print (order, file = h)
    h.close()

def batch_japan():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/CRC/japan/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/CRC/japan/result")
    h = open("/mnt/d/breakpoints/HGT/CRC/japan/run_localHGT_japan.sh", 'w')

    i = 0
    index = 0
    for line in open("/mnt/d/breakpoints/HGT/CRC/japan.csv"):
        array = line.split(",")
        if array[0] == "Run":
            continue
        else:
            if i > 80:
                break
            ba.sample = array[0]
            ba.fq1 = "/mnt/d/breakpoints/HGT/CRC/japan/%s_1.fastq.gz"%(ba.sample)
            ba.fq2 = "/mnt/d/breakpoints/HGT/CRC/japan/%s_2.fastq.gz"%(ba.sample)
            order = ba.get_normal_order()
            if not os.path.isfile("/mnt/d/breakpoints/HGT/CRC/japan/result/%s.repeat.acc.csv"%(ba.sample)):
                print (order, file = h)
            i += 1
    h.close()

def batch_japan_reverse():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/CRC/japan/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/CRC/japan/result")
    h = open("/mnt/d/breakpoints/HGT/CRC/japan/run_localHGT_japan_reverse.sh", 'w')
    order_list = []
    i = 0
    index = 0
    for line in open("/mnt/d/breakpoints/HGT/CRC/japan.csv"):
        array = line.split(",")
        if array[0] == "Run":
            continue
        else:
            if i > 80:
                break
            ba.sample = array[0]
            ba.fq1 = "/mnt/d/breakpoints/HGT/CRC/japan/%s_1.fastq.gz"%(ba.sample)
            ba.fq2 = "/mnt/d/breakpoints/HGT/CRC/japan/%s_2.fastq.gz"%(ba.sample)
            order = ba.get_normal_order()
            if not os.path.isfile("/mnt/d/breakpoints/HGT/CRC/japan/result/%s.repeat.acc.csv"%(ba.sample)):
                # print (order, file = h)
                order_list.append(order)
            i += 1
    for order in order_list[::-1]:
        print (order, file = h)
    h.close()

def batch_austria():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/CRC/austria/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/CRC/austria/result")

    h = open("/mnt/d/breakpoints/HGT/CRC/austria/run_localHGT_austria.sh", 'w')

    i = 0
    index = 0
    for line in open("/mnt/d/breakpoints/HGT/CRC/austria/austria.csv"):
        array = line.split(",")
        if array[0] == "Run":
            continue
        elif re.search("SINGLE", line):
            continue
        else:
            ba.sample = array[0]
            ba.fq1 = "/mnt/d/breakpoints/HGT/CRC/austria/%s_1.fastq.gz"%(ba.sample)
            ba.fq2 = "/mnt/d/breakpoints/HGT/CRC/austria/%s_2.fastq.gz"%(ba.sample)
            order = ba.get_normal_order()
            if not os.path.isfile("/mnt/d/breakpoints/HGT/CRC/austria/result/%s.repeat.acc.csv"%(ba.sample)):
                print (order, file = h)
    h.close()

def batch_USA():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/CRC/USA/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/CRC/USA/result")

    h = open("/mnt/d/breakpoints/HGT/CRC/USA/run_localHGT_USA.sh", 'w')

    i = 0
    index = 0
    for line in open("/mnt/d/breakpoints/HGT/CRC/USA/USA.list"):
        ID = line.strip()

        ba.sample = ID
        ba.fq1 = "/mnt/d/breakpoints/HGT/CRC/USA/%s_1.fastq.gz"%(ba.sample)
        ba.fq2 = "/mnt/d/breakpoints/HGT/CRC/USA/%s_2.fastq.gz"%(ba.sample)
        order = ba.get_normal_order()
        if not os.path.isfile("/mnt/d/breakpoints/HGT/CRC/USA/result/%s.repeat.acc.csv"%(ba.sample)):
            print (order, file = h)
    h.close()

def batch_china():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/CRC/china/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/CRC/china/result")

    h = open("/mnt/d/breakpoints/HGT/CRC/china/run_localHGT_china.sh", 'w')

    i = 0
    index = 0
    for line in open("/mnt/d/breakpoints/HGT/CRC/china/yu_2015.csv"):
        ID = line.strip().split(",")[0]
        if ID == "Run":
            continue

        ba.sample = ID
        ba.fq1 = "/mnt/f/PRJEB10878_crc_bgi/%s_1.fastq.gz"%(ba.sample)
        ba.fq2 = "/mnt/f/PRJEB10878_crc_bgi/%s_2.fastq.gz"%(ba.sample)
        order = ba.get_normal_order()
        if not os.path.isfile("/mnt/d/breakpoints/HGT/CRC/china/result/%s.repeat.acc.csv"%(ba.sample)):
            print (order, file = h)
    h.close()

def batch_donor():
    ba = Batch()

    ba.HGT_num = 5
    ba.scaffold_num = 5

    f = open("/mnt/d/breakpoints/lemon/run_lemon_donor.sh", 'w')
    h = open("/mnt/d/breakpoints/HGT/run_localHGT_donor.sh", 'w')

    index = 0
    # for snp_rate in [0.01, 0.02, 0.03, 0.04, 0.05]:
    for donor_f in ["in", "not_in"]:
        # ba.snp_rate = snp_rate 

        ba.get_fq_dir("/mnt/d/breakpoints/HGT/donor/%s/"%(donor_f))
        ba.get_result_dir("/mnt/d/breakpoints/HGT/donor_result/localhgt/%s/"%(donor_f))
        ba.change_lemon_dir("/mnt/e/HGT/donor_result/lemon/%s/"%(donor_f))
        for index in range(10):
            ba.get_ID(index)
            ba.get_fq()
            ba.change_ref()
            order = ba.get_lemon_order()
            print (order, file = f)
            order = ba.get_normal_order()
            print (order, file = h)
            ba.get_ID(index) # refresh ID

    f.close()
    h.close()

def batch_frag():
    ba = Batch()

    f = open("/mnt/d/breakpoints/lemon/run_lemon_frag.sh", 'w')
    h = open("/mnt/d/breakpoints/HGT/run_localHGT_frag.sh", 'w')


    # for frag in [500, 1000, 1500]:
    for frag in [200, 350, 500, 650, 800, 950]:
        ba.mean_frag = frag
        os.system("mkdir /mnt/d/breakpoints/HGT/frag_result/localhgt/f%s/"%(frag))
        os.system("mkdir /mnt/e/HGT/frag_result/lemon/f%s/"%(frag))
        ba.get_fq_dir("/mnt/d/breakpoints/HGT/frag_size/f%s/"%(frag) )
        ba.get_result_dir("/mnt/d/breakpoints/HGT/frag_result/localhgt/f%s/"%(frag))
        ba.change_lemon_dir("/mnt/e/HGT/frag_result/lemon/f%s/"%(frag))
        for index in range(10):
            ba.get_ID(index)
            ba.get_fq()
            ba.change_ref()
            order = ba.get_lemon_order()
            print (order, file = f)
            order = ba.get_normal_order()
            print (order, file = h)
            ba.get_ID(index) # refresh ID

    f.close()
    h.close()

def batch_depth_test_event_accuracy():
    ba = Batch()
    ba.get_fq_dir("/mnt/d/breakpoints/HGT/uhgg_depth/")
    ba.get_result_dir("/mnt/d/breakpoints/HGT/depth_for_event/")
    ba.change_lemon_dir("/mnt/e/HGT/lemon_depth/")

    h = open("/mnt/d/breakpoints/HGT/run_localHGT_depth_event.sh", 'w')

    i = 1
    index = 0
    for depth in [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]:
        ba.change_depth(depth)
        for index in range(10):
            ba.get_ID(index)
            ba.get_fq()
            ba.change_ref()
            order = ba.get_new_order()
            # print (order)
            print (order, file = h)
            ba.get_ID(index) # refresh ID

    h.close()

def isolate():
    reads_num=33336
    sample = "DRR198803"
    # rawdir= "//home/wangshuai/04.assembly/assembly/benchmark_data/"
    # outdir="//home/wangshuai/02.hgt/my_data5/08.deep//isolate_result//"
    rawdir="/mnt/d/breakpoints/assembly/sim/standard/filter/"
    outdir = "/mnt/d/breakpoints/HGT/isolate_result/"
    command_list=[]
    for i in range(1, 6):
        prop = i*10
        extract_num = round(reads_num * prop)
        order = ""
        for i in [1, 2]:
            raw_fq = rawdir + sample + "_%s.fastq"%(i)
            #raw_fq = outdir + sample + "_%s.fastq"%(i)
            new_fq = outdir + sample + "_prop%s_%s.fastq"%(prop, i)
            cmd = f"head -n {extract_num} {raw_fq} >{new_fq}\n"
            order += cmd
        run = """  ref=%s
                    main=/mnt/d/breakpoints/script/scripts/main.py
                    sample=%s
                    outdir=%s
                    ID=${sample}_prop%s
                    fq1=$outdir/${ID}_1.fastq
                    fq2=$outdir/${ID}_2.fastq

                    /usr/bin/time -v -o $outdir/$ID.time python -u $main -k 32 -a 0 --read_info 0 -t 10 -r $ref --fq1 $fq1 --fq2 $fq2 -s $ID -o $outdir >$outdir/${ID}.run.log
                    rm $outdir/$ID.*bam*
                    rm $fq1
                    rm $fq2\n"""%(uhgg_ref, sample, outdir, prop)
        order += run
        command_list.append(order)

    h = open("/mnt/d/breakpoints/HGT/isolate.sh", "w")
    for command in command_list:
        print (command, file = h)
    h.close()

if __name__ == "__main__":
    uhgg_ref = '/mnt/d/breakpoints/HGT/UHGG/UHGG_reference.formate.fna'
    progenomes = '/mnt/d/breakpoints/HGT/proGenomes/proGenomes_v2.1.fasta'
    # batch_frag()
    # batch_donor()
    # batch_snp_pure()
    # batch_length_pure()
    # batch_cami()
    # batch_depth()
    # batch_depth_test_event_accuracy()
    # batch_pro_cami()
    # batch_germany()
    # batch_japan()
    # batch_USA()
    # batch_austria()
    # batch_france()
    # batch_china()
    # batch_japan_reverse()
    isolate()