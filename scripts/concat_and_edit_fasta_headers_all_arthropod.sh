#!/bin/bash

#SBATCH -p test # Partition to submit to (comma separated)
#SBATCH -J concat # Job name
#SBATCH -n 1 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 10G
#SBATCH -t 00-08:00

# Location of genomes
cd "/n/netscratch/extavour_lab/Everyone/Rishabh/ncbi_dataset/data/" || exit 1

# Location of outputs 
odir='/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/hgt_pipeline_redo_2025/outputs'

for dir in */; do
  for file in "$dir"/protein.faa; do
    if [ -f "$file" ]; then
      # Prepend the directory name to each FASTA header in-place.
      sed -i "s/^>/>${dir%%/};/" "$file"
      
      cat "$file" >> "$odir/all_arthropod_concatenated_proteins.fa"
    fi
  done
done