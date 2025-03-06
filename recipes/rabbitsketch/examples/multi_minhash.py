import rabbitsketch as sketch
import fastx,time  
import pymp
from multiprocessing import Manager,Queue
import math
import numpy as np
import  dill as pickle
from dill import dumps, loads
file_list = []
t1 = time.time()
manager = Manager()
with open('YOUR_FILE_LIST_PATH', "r") as bact1000:
    for genomefile in bact1000:
        genomefile = genomefile.strip()
        file_list.append(genomefile)
#sketcharr = manager.list([[] for _ in range(128)])
print("length of file is:", len(file_list))
def write_to_file(file_name, content):
    with open(file_name, 'a', encoding='utf-8') as file:
        file.write(content)
with pymp.Parallel(128) as p:
    for index in p.xrange(0, len(file_list)):
            kssd = sketch.MinHash()
            for name, seq, qual in fastx.Fastx(file_list[index]):
                kssd.update(seq)
            #simply save results
            #write_to_file("SAVE_PATH"+str(p.thread_num)+".txt", kssd.printMinHashes())
t2 = time.time()
print("sketch time is :", t2-t1)
#sketch_list = [item for sublist in sketcharr for item in sublist]
#print("the sketch size is", sketch_list)
#result = [[] for _ in range(128)]
#with pymp.Parallel(128) as p:
#    for index in p.xrange(0, len(sketch_list)):
#        for j in range(index+1, len(sketcharr)):
#            result[p.thread_num].append(sketch_list[index],sketch_list[j])
#print(len(result))
#t3 = time.time()
#print("dist time is :", t3-t2)
