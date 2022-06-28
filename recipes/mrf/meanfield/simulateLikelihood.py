from unittest import expectedFailure
import numpy as np
from numpy.random import default_rng

import matplotlib.pyplot as plt
import sys
import scipy.special
import scipy.stats

from sklearn import datasets, linear_model
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.linear_model import PoissonRegressor, Ridge
from sklearn.pipeline import Pipeline

from scipy import stats

class CMeanFieldAnnealing:

    def __init__(self, Nproteins, Nk):
        self.lstExpectedLikelihood = []
        self.mIndicatorQ = np.zeros((Nproteins, Nk), dtype=float)
        
    def Likelihood(self, mObservationG, Nproteins, Nk, psi):

        rng = default_rng()

        # psi = (-np.log(fp) + np.log(1 - fn))/(-np.log(fn) + np.log(1 - fp))
        print('psi = ', psi)

        for i in range(Nproteins):
            self.mIndicatorQ[i,:] = rng.random(Nk)
            self.mIndicatorQ[i,:] /= sum(self.mIndicatorQ[i,:])

        nTemperature = 1000.0
        while nTemperature > 0.0:
            tmp = 1e-2
            mExpectation = 0.0
            nIteration = 0
            while not np.allclose(tmp, mExpectation, 1e-5):
                tmp = mExpectation
                mExpectation = 0.0
                for i in range(Nproteins):
                    # i = np.random.randint(0, Nproteins) # Choose a node at random
                    """ 
                    mLogLikelihood = np.zeros(Nk, dtype=float) # Negative log-likelihood
                    for k in range(Nk):
                        for j in mObservationG.lstAdjacency[i]:
                            t = mObservationG.mTrials[i][j]
                            s = mObservationG.mObserved[i][j]
                            assert(s <= t)
                            mLogLikelihood[k] += (self.mIndicatorQ[j][k]*float(t-s) + (1.0 - self.mIndicatorQ[j][k])*float(s)*psi)
                            ## mLogLikelihood[k] += self.mIndicatorQ[j][k]*(t-s-s*psi)
                    """

                    fn_out = np.dot(mObservationG.mTrials[i] - mObservationG.mObserved[i], self.mIndicatorQ) 
                    fp_out = np.dot(psi*mObservationG.mObserved[i], np.ones((Nproteins, Nk)) - self.mIndicatorQ)

                    mLogLikelihood = fn_out + fp_out

                    # Overflow problem. Need to compute with softmax
                    gamma = nTemperature
                    self.mIndicatorQ[i,:] = scipy.special.softmax(-gamma*mLogLikelihood)
                    ## self.mIndicatorQ[i,:] /= sum(self.mIndicatorQ[i,:])
                nIteration += 1
                mExpectation = np.sum(np.sum(self.mIndicatorQ, axis=0))
            print('Num. Iterations = ', nIteration)    
            print('Temperature: ', nTemperature, 'Expectation = ', mExpectation)
            nTemperature = nTemperature - 100.0
        return self.lstExpectedLikelihood

    ##
    ## Adapt from https://github.com/zib-cmd/cmdtools/blob/dev/src/cmdtools/analysis/optimization.py
    ##
    def inner_simplex_algorithm(self, X):
        """
        Return the transformation A mapping those rows of X
        which span the largest simplex onto the unit simplex.
        """
        ind = self.indexsearch(X)
        return np.linalg.inv(X[ind, :])

    def indexsearch(self, X):
        """ Return the indices to the rows spanning the largest simplex """

        k = np.size(X, axis=1)
        X = X.copy()

        ind = np.zeros(k, dtype=int)
        for j in range(0, k):
            # find the largest row
            rownorm = np.linalg.norm(X, axis=1)
            ind[j] = np.argmax(rownorm)

            if j == 0:
                # translate to origin
                X -= X[ind[j], :]
            else:
                # remove subspace of this row
                X /= rownorm[ind[j]]
                v  = X[ind[j], :]
                X -= np.outer(X.dot(v), v)

        return ind

    def find_lin_dependent(self):
        N = np.size(self.mIndicatorQ, axis=0)
        k = np.size(self.mIndicatorQ, axis=1)
        self.indicatorVec = np.zeros(N, dtype=int)
        ind = self.indexsearch(self.mIndicatorQ)
        for id in ind:
            for i in range(0,N):
                inner_product = np.inner(
                    self.mIndicatorQ[i],
                    self.mIndicatorQ[id])

                norm_i = np.linalg.norm(self.mIndicatorQ[i])
                norm_j = np.linalg.norm(self.mIndicatorQ[id])

                distance = np.abs(inner_product - norm_i*norm_j)
                if distance < 1E-5:
                    self.indicatorVec[i] = id
            self.indicatorVec[id] = id

    def find_argmax(self):
        N = np.size(self.mIndicatorQ, axis=0)
        k = np.size(self.mIndicatorQ, axis=1)
        self.indicatorVec = np.argmax(self.mIndicatorQ, axis=1)

    def computeErrorRate(self, mObservationG, Nproteins):
        
        # self.find_lin_dependent()
        self.find_argmax()

        rnk = np.linalg.matrix_rank(self.mIndicatorQ)
        print("Indicator matrix had rank = " + str(rnk))
        nClusters = len(np.unique(self.indicatorVec))
        print("Number of clusters used: " + str(nClusters))

        countFn = 0
        countFp = 0
        sumSameCluster = 0
        sumDiffCluster = 0
        for i in range(Nproteins):
            for j in mObservationG.lstAdjacency[i]:
                t = mObservationG.mTrials[i][j]
                s = mObservationG.mObserved[i][j]
                assert(s <= t)
                if (self.indicatorVec[i] == self.indicatorVec[j]):
                    countFn += (t - s)
                    sumSameCluster += t
                else:
                    countFp += s
                    sumDiffCluster += t

        fn = 0.0
        fp = 0.0
        if (sumSameCluster > 0):
            fn = float(countFn)/float(sumSameCluster)
        if (sumDiffCluster > 0):
            fp = float(countFp)/float(sumDiffCluster)
        return (fn, fp)

    def estimator_summary(self, regr, y_actual, y_pred):
        # The coefficients
        print("Coefficients: \n", regr.coef_)
        # The mean squared error
        print("Mean squared error: %.2f" % mean_squared_error(y_actual, y_pred))
        # The coefficient of determination: 1 is perfect prediction
        print("Coefficient of determination: %.2f" % r2_score(y_actual, y_pred))
        
    def computeResidues(self, mObservationG, Nproteins, Nk):
    
        (fn, fp) = self.computeErrorRate(mObservationG, Nproteins)

        # Filter singletons
        clusters = []
        singletons = []
        for k in range(Nk): 
            if (sum(self.indicatorVec == k) > 1):
                clusters.append(k)
            else:
                singletons.append(k)
        setProteins = set()
        indicators = dict()
        for i in range(Nproteins):
            if self.indicatorVec[i] in clusters: 
                setProteins.add(i)
                indicators[i] = self.indicatorVec[i]

        countFn = np.zeros(Nk)
        countFp = np.zeros(Nk)
        trialFn = np.zeros(Nk)
        trialFp = np.zeros(Nk)
        for i in setProteins:
            cl = indicators[i]    
            for j in mObservationG.lstAdjacency[i]:
                t = mObservationG.mTrials[i][j]
                s = mObservationG.mObserved[i][j]
                if (self.indicatorVec[i] == cl) and (self.indicatorVec[j] == cl):      
                    trialFn[cl] += t
                    countFn[cl] += (t - s)
                if (self.indicatorVec[i] == cl) and (self.indicatorVec[j] != cl):
                    countFp[cl] += s
                    trialFp[cl] += t

        self.expectedErrors = np.floor(fn*trialFn) + np.floor(fp*trialFp)
        self.mResidues = countFn + countFp

        expectedErrors = list( self.expectedErrors[i] for i in clusters)
        residues = list( self.mResidues[i] for i in clusters)
        result = scipy.stats.ks_2samp(residues, expectedErrors)
        print(result)


        self.expectedErrors = expectedErrors
        self.mResidues = residues

        X = np.reshape(expectedErrors, (-1,1))
        # Create linear regression object
        regr = linear_model.LinearRegression()
        # Train the model using the training sets
        regr.fit(X, residues)
        # Make predictions using the testing set
        y_pred = regr.predict(X)
        print("Linear Regression evaluation:")
        self.estimator_summary(regr, residues, y_pred)
        
        return (fn, fp)

    def computeEntropy(self, Nproteins, Nk):
        self.mEntropy = np.zeros(Nproteins, dtype=float)
        for i in range(Nproteins):
            for k in range(Nk):
                p = self.mIndicatorQ[i][k]
                if (p > 0):
                    self.mEntropy[i] += (-p*np.log(p))
        
    #
    # https://www.researchgate.net/publication/343831904_NumPy_SciPy_Recipes_for_Data_Science_Projections_onto_the_Standard_Simplex
    #
    def indicator2simplex(self):
        m,n = self.mIndicatorQ.shape
        matS = np.sort(self.mIndicatorQ, axis=0)
        matC = np.cumsum(matS, axis=0) - 1.
        matH = matS - matC / (np.arange(m) + 1).reshape(m,1)
        matH[matH<=0] = np.inf

        r = np.argmin(matH, axis=0)
        t = matC[r,np.arange(n)] / (r + 1)

        matY = self.mIndicatorQ - t
        matY[matY < 0] = 0
        return matY

    def clusterImage(self, matQ):
        m,n = matQ.shape
        vecArgMax = np.argmax(matQ,axis=1)
        vecIndices = np.argsort(vecArgMax)
        matImage = np.zeros((m,n), dtype=int)
        for i in range(len(vecIndices)):
            k = vecArgMax[vecIndices[i]]
            matImage[i][k] = 255
        return matImage
