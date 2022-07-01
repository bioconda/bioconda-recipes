import pandas as pd
import numpy as np

class CountBioplexSpoke:

    def __init__(self, filePath):

        df = pd.read_csv(filePath, sep='\t')

        df_filtered = df[df.apply(lambda x: not x['bait_symbol'].isnumeric() and x['bait_symbol'] != "nan", axis=1)]
        df_filtered = df[df.apply(lambda x: isinstance(x['symbol'], str) and not x['symbol'].isnumeric(), axis=1)]

        bait_list = np.array(df_filtered['bait_symbol'], dtype='U21')
        prey_list = np.array(df_filtered['symbol'], dtype='U21')

        proteins_list = np.append(bait_list, prey_list)
            
        self.nProteins = len(np.unique(proteins_list))
        nProteins = self.nProteins
        
        npSortedProteins = np.sort(np.unique(proteins_list))  # sorted proteins list
        bait_inds = np.searchsorted(npSortedProteins,bait_list) # array([[2, 1, 0, 2,...]])
        prey_inds = np.searchsorted(npSortedProteins,prey_list)
        # proteins_list = list(proteins_set)
        self.mObserved = np.zeros(shape=(nProteins, nProteins), dtype=int)
        nrows, ncols = df.shape
        for i,j in zip(bait_inds, prey_inds):
            # bait = df.loc[row,'bait_symbol']
            # prey = df.loc[row,'symbol']
            self.mObserved[i][j] += 1
            self.mObserved[j][i] += 1

        self.mTrials = np.zeros(shape=(nProteins, nProteins), dtype=int)
        bincounts = np.bincount(bait_inds)
        for i, k in enumerate(bincounts):
            self.mTrials[i,:] += k*np.ones(nProteins, dtype=np.int32)
            self.mTrials[:,i] += k*np.ones(nProteins, dtype=np.int32)
            
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