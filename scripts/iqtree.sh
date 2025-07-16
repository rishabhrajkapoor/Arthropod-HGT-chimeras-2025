#!/bin/bash
#SBATCH -p serial_requeue # Partition to submit to (comma separated)
#SBATCH -J iqtree # Job name
#SBATCH -n 20 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 25G
#SBATCH -t 2-00:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=END 
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=FAIL

cd "/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/hgt_pipeline_redo_2025/outputs/phylogenetic_dataset/$1/$2"

singularity exec /cvmfs/singularity.galaxyproject.org/i/q/iqtree:2.2.0.3--hb97b32f_0 iqtree2 -s trimmed_MSA.fasta -B 1000 -T AUTO --prefix ml_tree -safe