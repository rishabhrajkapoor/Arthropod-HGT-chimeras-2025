#!/bin/bash
#SBATCH -p sapphire # Partition to submit to (comma separated)
#SBATCH -J diamond # Job name
#SBATCH -n 40 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 350G
#SBATCH -t 1-00:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=FAIL
DB="/n/netscratch/extavour_lab/Everyone/Rishabh/mmseq_combined_output"
subDB="/n/netscratch/extavour_lab/Everyone/Rishabh/DB_clu_rep"
DB_clut="outputs/mmseq_combined_output.tsv"
DB_clu="/n/netscratch/extavour_lab/Everyone/Rishabh/cluster_concatenated_filtered_proteins"
fasta_out="outputs/mmseq_cluster_representatives.fasta"

singularity exec /cvmfs/singularity.galaxyproject.org/m/m/mmseqs2:14.7e284--pl5321hf1761c0_0 mmseqs cluster $DB $DB_clu "/n/netscratch/extavour_lab/Everyone/Rishabh/tmp" -c 0.80 --threads 30


##Output tsv of cluster representatives 
singularity exec /cvmfs/singularity.galaxyproject.org/m/m/mmseqs2:14.7e284--pl5321hf1761c0_0 mmseqs createtsv $DB $DB $DB_clu $DB_clut

singularity exec /cvmfs/singularity.galaxyproject.org/m/m/mmseqs2:14.7e284--pl5321hf1761c0_0 mmseqs createsubdb $DB_clu $DB $subDB

##Output clustered fasta 
singularity exec /cvmfs/singularity.galaxyproject.org/m/m/mmseqs2:14.7e284--pl5321hf1761c0_0 mmseqs convert2fasta $subDB outputs/mmseq_cluster_representatives.fasta  