#!/bin/bash

mkdir -p "/n/netscratch/extavour_lab/Everyone/Rishabh/round1_diamond_split_outputs"

# Parent output directory
for file in /n/netscratch/extavour_lab/Everyone/Rishabh/round1_diamond_out/*.tsv; do
    sbatch "scripts/split_blast_table.sh" "$file" "/n/netscratch/extavour_lab/Everyone/Rishabh/round1_diamond_split_outputs"
done
