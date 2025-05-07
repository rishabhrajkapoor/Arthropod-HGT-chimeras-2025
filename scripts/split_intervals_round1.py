import pickle
import pandas as pd
import multiprocessing as mp
import numpy as np
import pickle
import matplotlib.pyplot as plt
from Bio import SeqIO
import os
import subprocess
import ast

record_dict = SeqIO.to_dict(SeqIO.parse('outputs/concatenated_filtered_proteins.fa', 'fasta'))
a=open("interval_demarcation_results.txt","r").readlines()
a=[ai.replace("\n","") for ai in a]

#parse the interval annotations and store in a dictionary key=query, value=lst of interval tuples 
result = {}
for item in a:
    parts = item.split(":", 1)

    key = parts[0]

    values = item.replace(key+":","").split("', ")

    new_value = {}
    if len(values)>=1 and values[0]!="[]":

        for v in values:

            v_parts = v.replace('"',"").replace("[","").replace("]","").replace("'","").split(":")
            new_value[ast.literal_eval(v_parts[1])] = v_parts[0]
        result[key] = new_value

#determine putatitive chimeras as sequences w/ at least 1 meta AND HGT interval         
def is_chimera(ai):
    if "HGT" in ai and "Meta" in ai:
        return ai
with mp.Pool(40) as p:
    chimera_candidates = p.map(is_chimera,a) 
cc=[x for x in chimera_candidates if x!=None]
cc=[x.split(":")[0] for x in cc]

chimeras={x:result[x] for x in cc}
import pickle
with open('outputs/round1_chimera_intervals.pickle', 'wb') as handle:
    pickle.dump(chimeras, handle, protocol=pickle.HIGHEST_PROTOCOL)
    
## write demarcated intervals +/-10 to a fasta
def write_split_fasta(args):
    n, intervals = args
    s = record_dict[n]
    fasta_entries = []

    for interval in intervals:
        start = interval[0]
        stop = interval[1]
        a = s.seq[max(start - 10, 0):min(stop + 10, len(s.seq))]
        header = f">{n};{chimeras[n][interval]}_{interval}".replace(" ", "")
        fasta_entries.append(f"{header}\n{a}\n")

    return "".join(fasta_entries)

# Prepare inputs as list of (name, intervals) tuples
input_data = list(chimeras.items())


with mp.Pool(processes=40) as pool:
    results = pool.map(write_split_fasta, input_data)

# Write all FASTA entries to file
with open("outputs/split_intervals.fasta", "w") as f:
    f.writelines(results)