import rabbitsketch as sketch
import fastx,time  
import pymp
THREAD_NUM = 64
file_list = []
t1 = time.time()
half_k = 10
half_subk = 6
drlevel = 3
info = sketch.SketchInfo()
info.half_k = half_k
info.half_subk = half_subk
info.drlevel = drlevel

file_path = "shuf_file/L3K10.shuf"
kssd_para = sketch.kssd_parameter_t(half_k, half_subk, drlevel, file_path)
vkssd = pymp.shared.list()
with open('100.list', "r") as bact1000:
    for genomefile in bact1000:
        genomefile = genomefile.strip()
        file_list.append(genomefile)
print("length of file is:", len(file_list))
def write_to_file(file_name, content):
    with open(file_name, 'a', encoding='utf-8') as file:
        file.write(content)
with pymp.Parallel(THREAD_NUM) as p:
    for index in p.xrange(0, len(file_list)):
            
            kssd = sketch.Kssd(kssd_para)
            kssd.fileName = file_list[index]
            for name, seq, qual in fastx.Fastx(file_list[index]): 
                kssd.update(seq)
            
            kssd_lite = kssd.toLite()
            vkssd.append(kssd_lite)

print(len(vkssd))
info.genomeNumber = len(vkssd)
sketch.save_sketches(vkssd, info, "pysketch")

t2 = time.time()
print("sketch time is :", t2-t1)

sketch.trans_sketches(vkssd, info, "pysketch.dict", "pysketch.index", THREAD_NUM)
t3 = time.time()
print("trans time is :", t3-t2)

sketch.index_dict(vkssd, info, "pysketch", "pysketch.dist", 20, 1, 0, THREAD_NUM)
t4 = time.time()
print("dist time is :", t4-t3)
