import pandas as pd
import subprocess

df=pd.read_csv('Data/genbank_genomes_4_22_2025.tsv',sep='\t',index_col=0)
for x in set(df.index):
    subprocess.run(["scripts/download_genome.sh",x])

df=pd.read_csv('Data/refseq_genomes_scaffold_plus_4_19_2025.tsv',sep='\t',index_col=0)
for x in set(df.index):
    subprocess.run(["scripts/download_genome.sh",x])
