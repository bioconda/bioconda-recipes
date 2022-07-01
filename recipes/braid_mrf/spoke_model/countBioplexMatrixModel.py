import pandas as pd
import numpy as np

class CountBioplexMatrix:

    def __init__(self, filePath):

        df = pd.read_csv(filePath, sep='\t')

        bait_set = set()
        prey_set = set()

        for bait in df['bait_symbol']:
            if (isinstance(bait, str)) and not bait.isdigit():
                bait_set.add(bait)

        for prey in df['symbol']:
            if (isinstance(prey, str)) and not prey.isdigit():
                prey_set.add(prey)

        proteins_set = prey_set.union(bait_set)

        print('Number of baits = ', len(bait_set))
        print('Number of preys = ', len(prey_set))
        print('Number of proteins = ', len(proteins_set))
            
        self.nProteins = len(proteins_set)
        nProteins = len(proteins_set)
        self.mObserved = np.zeros(shape=(nProteins, nProteins), dtype=int)
        
        proteins_list = list(proteins_set)
        proteins_list.sort()
        indices = dict()
        for prot in proteins_list:
            indices[prot] = proteins_list.index(prot)
        nrows, ncols = df.shape
        for bait, prey in zip(df['bait_symbol'], df['symbol']):
            if (isinstance(prey, str)) and not prey.isdigit():
                i = indices[bait]
                j = indices[prey]
                self.mObserved[i][j] += 1
                self.mObserved[j][i] += 1

        self.mTrials = np.zeros(shape=(nProteins, nProteins), dtype=int)
        for bait, prey in zip(df['bait_symbol'], df['symbol']):
            i = indices[bait]
            for j in range(nProteins):
                self.mTrials[i][j] += 1
                self.mTrials[j][i] += 1
            if (isinstance(prey, str)) and not prey.isdigit():
                k = indices[prey]
                for j in range(nProteins):
                    self.mTrials[k][j] += 1
                    self.mTrials[j][k] += 1
                
        for i in range(nProteins):
            assert(np.sum(self.mTrials[i,:]) == np.sum(self.mTrials[:,i]))

        #
        # Create the adjacency list
        #
        self.lstAdjacency = {}
        for i in np.arange(nProteins):
            self.lstAdjacency[i] = []
            for j in np.arange(nProteins):
                t = self.mTrials[i][j]
                if (i < j):
                    s = self.mObserved[i][j] 
                else:
                    s = self.mObserved[j][i] 
                if (i != j and t > 0):
                    assert(s <= t)
                    self.lstAdjacency[i].append(j)

    def write2cytoscape(self, indicators, matQ, vecProteins):
        nRows, nCols = matQ.shape
        with open("out.sif", "w") as fh:
            for i in np.arange(nRows):
                for j in self.lstAdjacency[i]:
                    t = self.mTrials[i][j]
                    if (i >= j):
                        continue
                    if (t > 0 and indicators[i] == indicators[j]):
                        fh.write(str(vecProteins[i]) + '\t' + str(indicators[i]) + '\t' + str(vecProteins[j]) + '\n')
            fh.close()