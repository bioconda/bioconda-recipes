import numpy as np
import pandas as pd

#
# TODO: cpmFunc can be countSpokeModel or countMatrixModel
#
class CInputBioplex:

    def __init__(self, filePath, cpmFunc):
        super().__init__()

        df = pd.read_csv(filePath, sep='\t')

        df_filtered = df[df.apply(lambda x: not x['bait_symbol'].isnumeric() and x['bait_symbol'] != "nan", axis=1)]
        df_filtered = df[df.apply(lambda x: isinstance(x['symbol'], str) and not x['symbol'].isnumeric(), axis=1)]

        bait_list = np.array(df_filtered['bait_symbol'], dtype='U21')
        prey_list = np.array(df_filtered['symbol'], dtype='U21')

        proteins_list = np.append(bait_list, prey_list)
            
        self.nProteins = len(np.unique(proteins_list))
        nProteins = self.nProteins

        print('Number of baits = ', len(np.unique(bait_list)))
        print('Number of preys = ', len(np.unique(prey_list)))
        print('Number of proteins = ', nProteins)

        self.aSortedProteins = np.sort(np.unique(proteins_list))  # sorted proteins list
        
        for v in self.aSortedProteins[:100]:
            print(v)

        self.observationG = cpmFunc(filePath)

    def writeCluster2File(self, matQ, indVec):
        nRows, nCols = matQ.shape
        with open("bioplex_out.tab", "w") as fh:
            for i in range(nRows):
                ind = indVec[i]
                fh.write(str(self.aSortedProteins[i]) + '\t' + str(indVec[i]) + '\t' + str(max(matQ[ind])) + '\n')
            fh.close()
        with open("bioplex_out.csv", "w") as fh:
            for k in range(nCols):
                inds = list(i for i in range(nRows) if k == indVec[i])
                for i in inds:
                    fh.write(self.aSortedProteins[i] + '\t')
                fh.write('\n')
            fh.close()