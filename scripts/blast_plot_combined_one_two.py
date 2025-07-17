from ete3 import NCBITaxa
from Bio import SeqIO
import warnings
warnings.filterwarnings('ignore')
ncbi = NCBITaxa()
import multiprocessing as mp
import sys
import matplotlib.pyplot as plt

import matplotlib.font_manager
from matplotlib.font_manager import FontProperties

from pathlib import Path

import matplotlib as mpl
from matplotlib.patches import Patch
from matplotlib.lines import Line2D
import pandas as pd
import numpy as np
import sys
import os



fpath = Path(mpl.get_data_path(), "/n/holylabs/LABS/extavour_lab/Users/rkapoor/envs/plot/fonts/arial.ttf")
from matplotlib.font_manager import FontProperties
from matplotlib import font_manager
plt.rcParams['figure.dpi'] = 300
font_path = "/n/holylabs/LABS/extavour_lab/Users/rkapoor/envs/plot/fonts/arial.ttf"
font_manager.fontManager.addfont("/n/holylabs/LABS/extavour_lab/Users/rkapoor/envs/plot/fonts/arial.ttf")
prop = font_manager.FontProperties(fname=font_path)
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = prop.get_name()
import pickle
file_path = 'outputs/round2_chimera_intervals.pickle'
with open(file_path, 'rb') as file:
    chimeras=pickle.load(file)

if 'length_map.pickle' not in os.listdir('outputs'):
    ##load fasta of all arthropod proteins in original search database
    all_seqs = SeqIO.to_dict(SeqIO.parse('outputs/all_arthropod_concatenated_proteins.fa', 'fasta'))
    ##output a dictionary of all protein lengths, useful for plotting
    lmap={x:len(record_dict[x].seq) for x in record_dict}
    with open('outputs/length_map.pickle', 'wb') as file:
        pickle.dump(lmap,file)



with open('outputs/length_map.pickle', 'rb') as file:
    lmap=pickle.load(file)

floor = 1e-200
    
def get_color(ann):
    if "Viruses" in ann:
        return "yellow"
    if "Bacteria" in ann:
        return "blue"
    if "Fungi" in ann:
        return "brown"
    elif "Viridiplantae" in ann:
        return "green"
    elif "Arthropoda" in ann:
        return "pink"
    elif "Metazoa" in ann:
        return "orange"
    else:
        return "black"

def get_taxid(ti):
    try:
        if str(ti)!= 'nan':
            
            ti = int(ti)
            ncbi = NCBITaxa()
            lineage = ncbi.get_lineage(ti)
            ranks = ncbi.get_rank(lineage)
            names = ncbi.get_taxid_translator(lineage)
            rank_to_name = {r: names[t] for t, r in ranks.items() if t in names}

            sk = rank_to_name.get("superkingdom", "nan")
            k  = rank_to_name.get("kingdom", "nan")
            p  = rank_to_name.get("phylum", "nan")
            o  = rank_to_name.get("order", "nan")

            lineage_names = list(names.values())
            c = get_color(" ".join(lineage_names))
            return (ti, sk, k, p, o, c)
        else:
            return (np.nan,np.nan,np.nan, np.nan,np.nan,np.nan)
    except:
        return (np.nan,np.nan,np.nan, np.nan,np.nan,np.nan)
    
    
def plot(n):
    fig, ax = plt.subplots(1, 2, dpi=300, figsize=(8, 4))
    ints = chimeras[n]


    # Function to add tax data and plot
    def plot_round1(n, ax_i=0):
        ##load data, exclude rotifer and arthropod hits
        file_path = f"outputs/round1_diamond_output/{n}.tsv"
        df_sub=pd.read_csv(file_path, sep="\t", dtype={"staxids": str}, nrows=2e4)
        df_sub = df_sub[~df_sub.sphylums.astype(str).str.contains("Rotifera")]
        df_sub = df_sub[~df_sub.sphylums.astype(str).str.contains("Arthropoda")]
        df_sub=df_sub[df_sub.staxids.astype(str)!='nan']
        df_sub.index=list(range(df_sub.shape[0]))
        td = df_sub["staxids"].str.split(";").str[0].astype(float)
        unique_tds = list(set(td))

        # Parallel taxonomic data fetching
        with mp.Pool(30) as pool:
            taxid_data = dict(zip(unique_tds, pool.map(get_taxid, unique_tds)))
        data = [taxid_data.get(t) for t in td]
        df=pd.DataFrame(data,columns=["taxid", "superkingdom", "kingdom", "phylum", "order", "color"])
        df_sub=pd.concat([df_sub,df],axis=1)
        d = df_sub[df_sub["color"].astype(str).notnull() & (df_sub["color"] != "nan")]
        d["color"] = d["color"].fillna("black")

        
        for _, row in d.iterrows():
            ax[ax_i].hlines(np.log10(float(row["evalue"]) + floor), float(row["qstart"]), float(row["qend"]), color=row["color"], linewidth=1)
        ax[ax_i].set_xlabel("Position with respect to query (N-C)", font=fpath)
        ax[ax_i].set_ylabel("Log10(E-value+1e-200)", font=fpath)
        ax[ax_i].set_title("Round 1 Blast Results", font=fpath)
        del df_sub
        
    def plot_round2(n,ax_i=1):
        ##interate through round2 blast results
        for inter in ints:
            inter_name=n+";"+chimeras[n][inter]+"_"+str(inter).replace(" ","")
            ##filter out arthropod hits
            file_path = f'outputs/round2_diamond_output_split/{inter_name}.tsv'
            df_sub=pd.read_csv(file_path,dtype={"staxids": str},sep="\t",index_col=0,nrows=2e4)
            df_sub = df_sub[~df_sub.sphylums.astype(str).str.contains("Rotifera")]
            df_sub=df_sub[~df_sub.sphylums.astype(str).str.contains('Arthropod')]
            df_sub=df_sub[df_sub.staxids.astype(str)!='nan']
            df_sub.index=list(range(df_sub.shape[0]))
            td = df_sub["staxids"].str.split(";").str[0].astype(float)
            unique_tds = list(set(td))

            # Parallel taxonomic info fetching
            with mp.Pool(30) as pool:
                taxid_data = dict(zip(unique_tds, pool.map(get_taxid, unique_tds)))
            data = [taxid_data.get(t) for t in td]
            df=pd.DataFrame(data,columns=["taxid", "superkingdom", "kingdom", "phylum", "order", "color"])
            df_sub=pd.concat([df_sub,df],axis=1)
            d = df_sub[df_sub["color"].astype(str).notnull() & (df_sub["color"] != "nan")]
            d["color"] = d["color"].fillna("black")



            ##extract the start coordinates of the interval
            start,stop=inter
            ##blast queries were separated intervals -10 of start, so to get coordinates on the whole protein, 
            ## need to add the start of the interval-10 to qstart/qend 
            shift=max(start-10,0)
            ##plot each blast hit, shifting the qstart/qend appropriately
            for index, row in d.iterrows():
                ax[ax_i].hlines(np.log10(float(row["evalue"])+floor),shift+float(row["qstart"]),shift+float(row["qend"]),color=row["color"],linewidth=1)

        ax[ax_i].set_xlabel("Position with respect to query (N-C)", font=fpath)
        ax[ax_i].set_title("Round 2 Blast Results ", font=fpath)
        del df_sub





    plot_round1(n, 0)
    plot_round2(n, 1)

    legend_elements = [
        Line2D([0], [0], color='yellow', lw=3, label='Viruses'),
        Line2D([0], [0], color='blue', lw=3, label='Bacteria'),
        Line2D([0], [0], color='brown', lw=3, label='Fungi'),
        Line2D([0], [0], color='green', lw=3, label='Viridiplantae'),
        Line2D([0], [0], color='orange', lw=3, label='Non-Arthropod Metazoa'),
        Line2D([0], [0], color='black', lw=3, label='Other'),
        Line2D([0], [0], color='purple', lw=7, label='HGT interval'),
        Line2D([0], [0], color='orange', lw=7, label='Meta interval'),

    ]
    
    
    custom_font = FontProperties(fname=font_path, size=12)
    plt.legend(handles=legend_elements, bbox_to_anchor=(1.04, 1), loc="upper left", prop=custom_font)


    mn0 = ax[0].get_ylim()[0] - .10 * (ax[0].get_ylim()[1] - ax[0].get_ylim()[0])
    mn1 = ax[1].get_ylim()[0] - .10 * (ax[1].get_ylim()[1] - ax[1].get_ylim()[0])
    ##add bars for interval annotatations 
    for y in ints:

        ax[0].hlines(mn0, y[0], y[1], "purple" if ints[y] == "HGT" else "orange", linewidth=7.0)

        ax[1].hlines(mn1, y[0], y[1], "purple" if ints[y] == "HGT" else "orange", linewidth=7.0)

    ax[0].set_xlim(-20, lmap[n] + 20)
    ax[1].set_xlim(-20, lmap[n] + 20)
    odir=f"outputs/blast_result_plots_no_arthropod/{n}.svg"
    plt.savefig(odir, format="svg", bbox_inches="tight")
    plt.close(fig)

n = len(chimeras) // 4          # size of each chunk
parts = [list(chimeras)[i*n:(i+1)*n]  for i in range(4)]
print(int(sys.argv[1]))
to_do=parts[int(sys.argv[1])]

for n in to_do:
    if n+'.svg' not in os.listdir('outputs/blast_result_plots_no_arthropod'):
        plot(n)
    