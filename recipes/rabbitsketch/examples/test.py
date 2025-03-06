import rabbitsketch as sketch
import fastx

msh1 = sketch.MinHash()
msh2 = sketch.MinHash()
print('seed:' + str(msh1.getSeed()))
print('sketchsize:' + str(msh2.getSketchSize()))

#wmsh1 = sketch.WMinHash()
#wmsh2 = sketch.WMinHash()
#print('init the wmsh1 and wmsh2')


for name, seq, qual in fastx.Fastx('genome1.fna'):
    msh1.update(seq)
#    wmsh1.update(seq)
    omsh1 = sketch.OrderMinHash(seq)
for name, seq, qual in fastx.Fastx('genome2.fna'):
    msh2.update(seq)
#    wmsh2.update(seq)
    omsh2 = sketch.OrderMinHash(seq)

jac = msh1.jaccard(msh2)
#wjac = wmsh1.wJaccard(wmsh2)
odist = omsh1.distance(omsh2)
print("mh  distance(1-JAC): ", 1.0-jac)
#print("wmh distance(1-JAC): ", 1.0-wjac)
print("omh disntace       : ", odist)
