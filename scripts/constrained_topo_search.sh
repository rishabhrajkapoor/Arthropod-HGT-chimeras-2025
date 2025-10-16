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

cd "outputs/penaeus_topology_tests/"

# singularity exec /cvmfs/singularity.galaxyproject.org/i/q/iqtree:2.2.0.3--hb97b32f_0 iqtree2 -g $1.txt -m Q.pfam+I+I+R10 -s trimmed_MSA_edit_names.fasta -T AUTO --prefix $1 -safe


singularity exec /cvmfs/singularity.galaxyproject.org/i/q/iqtree:2.2.0.3--hb97b32f_0 iqtree2 -s trimmed_MSA_edit_names.fasta -m Q.pfam+I+I+R10 -z combo.treels -n 0 -zb 10000 -au -T AUTO --prefix topo_tests