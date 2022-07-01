
import numpy as np

#
# TODO: cpmFunc can be countSpokeModel or countMatrixModel
#
class CInputSet:

    def __init__(self, filename, cpmFunc):
        super().__init__()

        listBaits = list()
        with open(filename) as fh:
            setProteins = set()
            for line in fh:
                lst = line.rstrip().split(',')
                bait = lst[0]
                listBaits.append(bait)
                setProteins = setProteins.union(set(lst))
            print('Number of proteins ' + str(len(setProteins)))
            fh.close()

        self.aSortedProteins = np.sort(np.array(list(setProteins), dtype='U21'))
        bait_inds = np.searchsorted(self.aSortedProteins, np.array(listBaits, dtype='U21'))
        
        print('Number of purifications ' + str(len(bait_inds)))

        nProteins = len(self.aSortedProteins)
        incidence = np.zeros(shape=(len(bait_inds), nProteins), dtype=int)
        with open(filename) as fh:
            lineCount = 0
            for line in fh:
                lst = line.rstrip().split(',')
                prey_inds = np.searchsorted(self.aSortedProteins, np.array(lst, dtype='U21'))           
                for id in prey_inds:
                    incidence[lineCount][id] = 1
                lineCount += 1
            fh.close()
            
        self.observationG = cpmFunc(nProteins, bait_inds, incidence)

    def writeCluster2File(self, matQ, indVec):
        nRows, nCols = matQ.shape
        with open("out.tab", "w") as fh:
            for i in range(nRows):
                ind = indVec[i]
                fh.write(self.aSortedProteins[i] + '\t' + str(indVec[i]) + '\t' + str(max(matQ[ind])) + '\n')
            fh.close()
        with open("out.csv", "w") as fh:
            for k in range(nCols):
                inds = [i for i in range(nRows) if k == indVec[i]]
                for i in inds:
                    prot = self.aSortedProteins[i].split("__")[0]
                    fh.write(prot + '\t')
                fh.write('\n')    
            fh.close()