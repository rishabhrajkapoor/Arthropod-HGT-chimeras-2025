#!/bin/bash
#SBATCH -p sapphire # Partition to submit to (comma separated)
#SBATCH -J phylopipe # Job name
#SBATCH -n 20 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 25G
#SBATCH -t 01-00:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=FAIL

cd 'tsa_cluster_14'

singularity exec /cvmfs/singularity.galaxyproject.org/m/u/muscle:5.1--h4ac6f70_3 muscle -align $1.fasta -output $1_MSA.fasta -threads 20

singularity exec /cvmfs/singularity.galaxyproject.org/t/r/trimal:1.4.1--h9f5acd7_7 trimal -in $1_MSA.fasta -out $1_trimmed_MSA.fasta -gt 0.6 

singularity exec /cvmfs/singularity.galaxyproject.org/i/q/iqtree:2.2.0.3--hb97b32f_0 iqtree2 -s $1_trimmed_MSA.fasta -B 1000 -T AUTO --prefix $1 -safe