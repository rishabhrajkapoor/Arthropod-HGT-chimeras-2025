import pickle
import pandas as pd
import multiprocessing as mp
import numpy as np
import pickle
from Bio import SeqIO
import os
import subprocess
import sys
import warnings
warnings.filterwarnings('ignore')
#written by RK with chatGPT


#load fasta w/ all queries 
record_dict = SeqIO.to_dict(SeqIO.parse('outputs/concatenated_filtered_proteins.fa', 'fasta'))

def get_overlapping_rows(df, x, N=False):
    """
    Returns a new DataFrame with all rows from the input DataFrame that overlap with the given position x.
    """
    overlapping_rows = df[(df['qstart'] <= x) & (df['qend'] >= x)]
    if N:
        return overlapping_rows.shape[0]
    return overlapping_rows


def count_overlapping_seqs(df, start, end):
    """
    Input: a df with blast hits and start, end coordinates for the length of the query 
    Returns an array of positions and an array of the number of overlapping blast hits for each position
    """
    # Create an interval index from the qstart and qend columns
    intervals = pd.IntervalIndex.from_arrays(df['qstart'], df['qend'], closed='both')
    
    # Create a Boolean index of intervals that overlap with the start and end positions
    mask = intervals.overlaps(pd.Interval(start, end, closed='both'))
    
    # Use the Boolean index to select the overlapping intervals and count the number of occurrences
    counts = intervals[mask].value_counts(sort=False)
    
    # Create a Series of counts for each position between the start and end
    positions = np.arange(start, end)
    num_seqs = np.zeros_like(positions)
    for i, pos in enumerate(positions):
        for interval in counts.index:
            if pos in interval:
                num_seqs[i] += 1
    
    return positions, num_seqs

def max_y_x(x, y):
    """
    Returns the x value corresponding to the maximum y value in the given x and y arrays.
    """
    max_y_index = np.argmax(y)  # Find the index of the maximum y value
    return x[max_y_index]  # Return the x value at that index

def merge_intervals(intervals, overlap_frac=0.15):
    """
    Remove any interval whose overlap with a neighbour with a greater number of blast hits
    exceeds 15% (symmetrically measured).

    Inputs:
    intervals : dict[(int, int), int]
        Keys are (start, end) tuples, values are blast hit counts.
    overlap_frac : float, default 0.15
        Fraction of either interval that must be overlapped to trigger removal.

    Returns: dict[(int, int), int] without the merged intervals 
    """
    intervals = intervals.copy()                
    changed = True

    while changed:
        changed = False
        keys = list(intervals.keys())          

        for i in range(len(keys)):
            if keys[i] not in intervals:        # might have been deleted
                continue
            start1, end1 = keys[i]
            len1 = end1 - start1 + 1

            for j in range(i + 1, len(keys)):
                if keys[j] not in intervals:
                    continue
                start2, end2 = keys[j]
                len2 = end2 - start2 + 1

                # overlap length
                overlap = max(0, min(end1, end2) - max(start1, start2) + 1)
                if overlap == 0:
                    continue

                # check symmetric overlap fractions
                if (overlap / len1 > overlap_frac) or (overlap / len2 > overlap_frac):
                    # keep the higher-hit interval
                    if intervals[keys[i]] >= intervals[keys[j]]:
                        del intervals[keys[j]]
                    else:
                        del intervals[keys[i]]
                        break                   
                    changed = True

    return intervals

def find_peak_interval(pos,cov,dfi,f=.20):
    """
    Input: array of positions, array of blast hit density by position, dataframe with blast hits, 
    threshold density cutoff (float) for intervals 
    
    Runs interval demarcation algorithm modified from Bréhélin et al. PLOS Computational Biology, 2018
    https://doi.org/10.1371/journal.pcbi.1005889
    
    Returns integer interval (start_trimmed, stop_trimmed), number of overlapping hits (integer)
    
    """
    #identify global maximum in blast hit density and all seqs overlapping with it
    peak=max_y_x(pos,cov)
    unstable=False
    C=get_overlapping_rows(dfi,peak)
    
    #set preliminary interval boundaries
    Ce=max(dfi.qend)
    Cs=min(dfi.qstart)
    
    #trim interval boundaries until both ends have at least f*max (peak) density
    N=C.shape[0]
    Ns=get_overlapping_rows(C, Cs, True)
    Ne=get_overlapping_rows(C, Ce, True)
    Cei=Ce
    Csi=Cs
    if Ns<f*N:
        Cs+=1
        unstable=True
    if Ne<f*N:
        Ce-=1
        unstable=True
    while unstable:
        Ns=get_overlapping_rows(C, Cs, True)
        Ne=get_overlapping_rows(C, Ce, True)

        if Ns>=f*N and Ne>=f*N:
            break
        else:
            if Ns<f*N:
                Cs+=1

            if Ne<f*N:
                Ce-=1
   
    return (Cei, Csi),(Cs, Ce),C

def get_annots(nam):
    """
    Input: name of a df in inter_blast_results directory (for a single query)
    Runs interval demarcation algorithm then applies HGT ancestry annotation to each interval
    Writes all metazoan and HGT intervals to "blast_round_one_interval_demarcation.txt" in name:interval list format
    
"""

    #load dataframeint
    dfo=pd.read_csv(f"/n/netscratch/extavour_lab/Everyone/Rishabh/round1_diamond_split_outputs/{nam}.tsv",sep="\t", names="qseqid sseqid stitle staxids sscinames sphylums skingdoms pident length mismatch gapopen qstart qend sstart send evalue bitscore".split(" "))
    
    ##output blast hit with header added
    dfo.to_csv(f"/n/netscratch/extavour_lab/Everyone/Rishabh/round1_diamond_split_outputs/{nam}.tsv",sep="\t")
    
    ##exclude arthropod hits
    dfo=dfo[~dfo.sphylums.astype(str).str.contains("Arthropoda")]
    df1=dfo.loc[:,["sseqid","qstart","qend","sstart","send"]]


    #iteratively assign blast hits to intervals until <10 hits left
    dfi=df1.copy()
    #dictionary storing interval:blast df 
    intermd={}
    #dictionary storing interval: # of blast hits
    interm={}
    while dfi.shape[0]>10:
        #obtain blast hit coverage for all positions in query 
        ret=count_overlapping_seqs(dfi,0,len(record_dict[nam].seq))

        interi,inter,df=find_peak_interval(ret[0],ret[1],dfi,.20)
        if interi!=None:
            dfi=dfi.drop(df.index)
            #saves interval and its number of overlapping hits if length of interval>35 residues and overlapping hits>10
            if inter[1]-inter[0]>35 and df.shape[0]>10:
                interm[inter]=df.shape[0]
                intermd[inter]=df
                del df
   
    #merges intervals with overlapping hits            
    d=merge_intervals(interm)
    d=dict(sorted(d.items()))

    #annotates ancestry of each interval as Meta (ancient metazoan), HGT, or neither. 
    inters=[]
    for di in d:
        df=intermd[di]
        dfm=dfo.loc[df.index,:]
        ## exclude rotifer hits 
        dfm=dfm[~dfm.sphylums.astype(str).str.contains("Rotifera")]
        dfm=dfm[dfm.sphylums.astype(str)!="nan"]
        dfm=dfm[dfm.staxids!=32630]
        ##extract non-arthropod metazoan hits
        dfmeta=dfm[dfm.skingdoms.astype(str).str.contains("Metazoa")]
        ##extract non-metazoan hits
        dfhgt=dfm[~dfm.skingdoms.astype(str).str.contains("Metazoa")]
        ##compute the alien index and metazoan index
        dfhgt["AI"]=np.log10(dfmeta.evalue.min()+1e-200)-np.log10(dfhgt.evalue+1e-200)
        dfmeta["MI"]=np.log10(dfhgt.evalue.min()+1e-200)-np.log10(dfmeta.evalue+1e-200)
        dfmi=dfm.iloc[0:300,:]
        dfmetai=dfmi[dfmi.skingdoms.astype(str).str.contains("Metazoa")]
        dfhgti=dfmi[~dfmi.skingdoms.astype(str).str.contains("Metazoa")]
        if dfm.shape[0]>0:
            if len(set(dfmeta[dfmeta.MI>1].staxids))>5 or (len(set(dfmetai.staxids))/len(set(dfmi.staxids))>=.50):
                inters.append(f"Meta:{di}")
            elif len(set(dfhgt[dfhgt.AI>5].staxids))>10 or (len(set(dfhgti.staxids))/len(set(dfmi.staxids))>=.95) :
                inters.append(f"HGT:{di}")
        del df, dfm, dfmeta, dfhgt, dfmi, dfmetai, dfhgti
        
    
 
    ##output demarcated intervals to a temporary file directory    
    with open(f"/n/netscratch/extavour_lab/Everyone/Rishabh/demarcation_tmp_outputs/{nam}_results.txt", "w") as f:
        f.write(f"{nam}:{str(inters)}")
        f.write("\n")
    f.close()
    del dfo, df1, dfi, intermd, interm, d, inters
    return

def run_interval_demarcation(x):
    try:
        get_annots(x)
    except Exception as e:
        error_message = str(e)
        f=open('interval_demarcation_error_logs.txt','a')
    
        f.write(f"Caught an error for {x}:{error_message}")
        f.close()

## set of sequences that successfully ran with diamond blast round 1
blast_outputs=set(os.listdir("/n/netscratch/extavour_lab/Everyone/Rishabh/round1_diamond_split_outputs/"))
blast_outputs=set([x.replace(".tsv","") for x in blast_outputs])


done=set([x.split("_results.txt")[0] for x in os.listdir('/n/netscratch/extavour_lab/Everyone/Rishabh/demarcation_tmp_outputs')])

td=blast_outputs-done
with mp.Pool(processes=60) as pool:
    result=pool.map(get_annots, td)


def read_file(fname):
    with open(fname, 'r') as f:
        return f.read()

import glob
## concatenate the outputs 
file_list = sorted(glob.glob("/n/netscratch/extavour_lab/Everyone/Rishabh/demarcation_tmp_outputs/*_results.txt"))

with mp.Pool(processes=60) as pool:
    contents = pool.map(read_file, file_list)

with open("outputs/interval_demarcation_results.txt", "w") as outfile:
    outfile.writelines(contents)
 