import rabbitsketch as sketch
import fastx
import time 

sketcharr = []
result = []
t1 = time.time() 
with open('1000.list', "r") as bact1000:
    for genomefile in bact1000:
        genomefile =genomefile.strip()
        msh1 = sketch.MinHash()
        for name, seq, qual in fastx.Fastx(genomefile):
            msh1.update(seq)
        sketcharr.append(msh1)
t2 = time.time() 
print("time of sktech is:",t2 - t1 )
for i in range(len(sketcharr)):
    for j in range(i, len(sketcharr)):
        result.append(sketcharr[i].jaccard(sketcharr[j]))
t3 = time.time() 
print("time of dist is:",t3 - t2 )
with open('result.txt', 'w') as file:
    for item in result:
            file.write(str(item) + '\n')
t4 = time.time() 
print("time of out is:",t4 - t3 )
