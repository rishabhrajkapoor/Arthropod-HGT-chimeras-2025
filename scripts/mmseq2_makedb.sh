#!/bin/bash
#SBATCH -p sapphire# Partition to submit to (comma separated)
#SBATCH -J diamond # Job name
#SBATCH -n 10 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 300G
#SBATCH -t 1-00:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=FAIL


singularity exec /cvmfs/singularity.galaxyproject.org/m/m/mmseqs2:14.7e284--pl5321hf1761c0_0 mmseqs createdb outputs/concatenated_filtered_proteins.fa /n/netscratch/extavour_lab/Everyone/Rishabh/mmseq_combined_output 
