import rabbitsketch as sketch
import fastx
import time 
sketcharr = []
result = []
with open('1000.list', "r") as bact1000:
    #params = sketch.KSSDParameters(10, 6, 3)
    for genomefile in bact1000:
        genomefile =genomefile.strip()
        kssd = sketch.HyperLogLog()
        for name, seq, qual in fastx.Fastx(genomefile):
            kssd.update(seq)
        sketcharr.append(kssd)
for i in range(len(sketcharr)):
    for j in range(i, len(sketcharr)):
        result.append(sketcharr[i].jaccard(sketcharr[j]))
with open('result.txt', 'w') as file:
    for item in result:
            file.write(str(item) + '\n')
