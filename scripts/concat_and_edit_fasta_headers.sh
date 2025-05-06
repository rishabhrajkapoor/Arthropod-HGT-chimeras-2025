#!/bin/bash

#SBATCH -p sapphire # Partition to submit to (comma separated)
#SBATCH -J concat # Job name
#SBATCH -n 10 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 300G
#SBATCH -t 1-00:00

# Location of genomes
cd "/n/netscratch/extavour_lab/Everyone/Rishabh/ncbi_dataset/data/" || exit 1

# Location of outputs (removed spaces around the equals sign)
odir='/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/hgt_pipeline_redo_2025/outputs'

for dir in */; do
  for file in "$dir"/filtered_sequences.faa; do
    if [ -f "$file" ]; then
      # Prepend the directory name to each FASTA header in-place.
      sed -i "s/^>/>${dir%%/};/" "$file"
      
      cat "$file" >> "$odir/concatenated_filtered_proteins.fa"
    fi
  done
done