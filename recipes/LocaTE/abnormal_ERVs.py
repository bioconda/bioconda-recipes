import numpy as np
import pandas as pd
from sklearn.cluster import DBSCAN

# read
with open("ERVFamily", 'r', encoding='utf-8') as file:
    ERVFamily = file.read()
gte = pd.read_table("genome_TE_length", header=None, sep=" ")
ste = pd.read_table("single_TE_length", header=None, sep=" ")
df = pd.merge(gte, ste,how="left",on=[0])

# relative ratio
df['sg'] = df["1_y"] / df["1_x"]
df = df.dropna(axis=0,how='any')

# parameter
## eps
# std_dev = df[~df[0].str.contains(ERVFamily)]['sg'].std()
# range_diff = 1.5 * (df[~df[0].str.contains(ERVFamily)]['sg'].max() - df[~df[0].str.contains(ERVFamily)]['sg'].min())
## min_samples
count_ERVs = len(df[df[0].str.contains(ERVFamily)])
count_others = len(df[~df[0].str.contains(ERVFamily)])

# fix the model
model_DBSCAN = DBSCAN(min_samples=count_others, eps=3)
outliers_DBSCAN = model_DBSCAN.fit_predict(np.array(df["sg"]).reshape(-1,1))
df["outliers_DBSCAN"] = outliers_DBSCAN

# output
df[0] = df[0].replace("\"","", regex=True)
df[0] = df[0].replace("Motif:","", regex=True)
df = df[df[0].str.contains(ERVFamily)]
df[df["outliers_DBSCAN"] == -1][0].to_csv("abnormal_ERVs",sep="\t",index=0,header=0)

