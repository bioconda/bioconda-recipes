import h5py
import numpy as np
import argparse
import time

start_time = time.time()

parser = argparse.ArgumentParser()
parser.add_argument('-d', '--data', type=str, required=True)
parser.add_argument('-p', '--predictions', type=str, required=True)
parser.add_argument('-t', '--threshold', type=float, default=0.5) # decides whether annotations have enough coverage 
                                                              
args = parser.parse_args()

# load data and predictions
h5_data = h5py.File(args.data,'r')
h5_preds = h5py.File(args.predictions,'r')
#print ("\nPredictions: ", h5_preds, "\n")
y = h5_data['/data/y']
cov = h5_data['/scores/by_bp']
preds = h5_preds['predictions']
threshold = args.threshold

# check for cov scores >0.5 -> check if predictions = y_true[cov > 0.5]
def high_coverage_correct_preds(preds, cov, y, threshold): 
    
    overall_consensus = np.zeros(4)
    overall_count = np.zeros(4)
    
    # loop over 20k bp chunks seperately to avoid memory errors
    n_chunks = preds.shape[0]
    for i in range(n_chunks):
        sum_chunk = []
        count_chunk = []
        
        # find positions where cov >= threshold
        cov_chunk = cov[i]
        where = np.where(cov_chunk >= threshold)
        
        # cut down chunks to positions meeting criteria mentioned above
        preds_chunk_prob = preds[i][where[0]] 
        y_chunk = y[i][where[0]]
        
        # convert probabilities to onehot encoding for comparison with onehot-encoded annotations 
        preds_chunk = np.zeros_like(preds_chunk_prob)
        preds_chunk[np.arange(len(preds_chunk_prob)), preds_chunk_prob.argmax(1)] = 1 
        # loop over columns (features) to calculate consensus for each
        for x in range(4):
            count = np.count_nonzero(y_chunk[:, x]) # needed for averaging later 
            if count != 0:
                pred_with_y = np.logical_and(preds_chunk[ :, x], y_chunk[:, x]).astype(np.int8)
                sum_cols = int(np.sum(pred_with_y, axis=0))
                sum_chunk = np.append(sum_chunk, sum_cols)
                count_chunk = np.append(count_chunk, count)
            else:
                sum_chunk = np.append(sum_chunk, 0)
                count_chunk = np.append(count_chunk, 0)
        
        # sanity print - set threshold to 0.0 
        #print ("\nsum_chunk:", sum_chunk,"\n  y_chunk:",count_chunk)
        
        overall_consensus = np.add(overall_consensus, sum_chunk)
        overall_count = np.add(overall_count, count_chunk)
    overall_consensus = np.divide(overall_consensus, overall_count) * 100
    overall_consensus = np.nan_to_num(overall_consensus, nan=-1) # just in case; normal data sets contain all feats
    print ("Percentage of correct predictions for regions with high coverage support(coverage > {}):".format(threshold))
    feats = ["IG", "UTR", "CDS", "Intron"]
    for i in range(4):
        print ("{}: {:.5}%".format(feats[i], overall_consensus[i]))
    
def low_coverage_correct_preds(preds, cov, y, threshold): 
    start_time = time.time()
    
    overall_consensus = np.zeros(4)
    overall_count = np.zeros(4)
    
    # loop over 20k bp chunks seperately to avoid memory errors
    n_chunks = preds.shape[0]
    for i in range(n_chunks):
        sum_chunk = []
        count_chunk = []
        
        # find positions where cov >= threshold
        cov_chunk = cov[i]
        where = np.where(cov_chunk < threshold)
        
        # cut down chunks to positions meeting criteria mentioned above
        preds_chunk_prob = preds[i][where[0]] 
        y_chunk = y[i][where[0]]
        
        # convert probabilities to onehot encoding for comparison with onehot-encoded annotations 
        preds_chunk = np.zeros_like(preds_chunk_prob)
        preds_chunk[np.arange(len(preds_chunk_prob)), preds_chunk_prob.argmax(1)] = 1 
        # loop over columns (features) to calculate consensus for each
        for x in range(4):
            count = np.count_nonzero(y_chunk[:, x]) # needed for averaging later 
            if count != 0:
                pred_with_y = np.logical_and(preds_chunk[ :, x], y_chunk[:, x]).astype(np.int8)
                sum_cols = int(np.sum(pred_with_y, axis=0))
                sum_chunk = np.append(sum_chunk, sum_cols)
                count_chunk = np.append(count_chunk, count)
            else:
                sum_chunk = np.append(sum_chunk, 0)
                count_chunk = np.append(count_chunk, 0)
        
        # sanity print - set threshold to 0.0 
        #print ("\nsum_chunk:", sum_chunk,"\n  y_chunk:",count_chunk)
        
        overall_consensus = np.add(overall_consensus, sum_chunk)
        overall_count = np.add(overall_count, count_chunk)
    overall_consensus = np.divide(overall_consensus, overall_count) * 100
    overall_consensus = np.nan_to_num(overall_consensus, nan=-1) # just in case; normal data sets contain all feats
    print ("Percentage of correct predictions for regions with low coverage support(coverage < {}):".format(threshold))
    feats = ["IG", "UTR", "CDS", "Intron"]
    for i in range(4):
        print ("{}: {:.5}%".format(feats[i], overall_consensus[i]))

high_coverage_correct_preds(preds, cov, y, threshold)
print ("_"*25)
low_coverage_correct_preds(preds, cov, y, threshold)

elapsed_time = time.time() - start_time
print ("\nElapsed time: {:.3f}s".format(elapsed_time))
