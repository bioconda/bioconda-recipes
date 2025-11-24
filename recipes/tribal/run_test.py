"""
Vignette to demonstrate the capabilities of the tribal package.
"""

from tribal.preprocess import preprocess
from tribal import df, roots
from tribal import Tribal


if __name__ == "__main__":

    isotypes = ['IGHM', 'IGHG3', 'IGHG1', 'IGHA1','IGHG2','IGHG4','IGHE','IGHA2']

    #test that dnapars installed correctly by running it during preprocessing
    clonotypes, df_filt = preprocess(df, roots,isotypes, cores=3, verbose=True )

    #test that the tribal package is working
    tr = Tribal(n_isotypes=len(isotypes), verbose=True, restarts=1, niter=15)
          
    #run in refinement mode
    shm_score, csr_likelihood, best_scores, transmat = tr.fit(clonotypes=clonotypes, mode="refinement", cores=6)