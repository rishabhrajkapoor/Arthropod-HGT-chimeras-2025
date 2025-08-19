#!/bin/bash
#SBATCH -p serial_requeue # Partition to submit to (comma separated)
#SBATCH -J iqtree # Job name
#SBATCH -n 25 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 25G
#SBATCH -t 2-10:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=FAIL


cd $1

if [ ! -f "trimmed_MSA_hmm_output_final.fasta" ]; then
  singularity exec /cvmfs/singularity.galaxyproject.org/m/u/muscle:5.1--h4ac6f70_3 muscle -align concatenated_prot.fasta -output MSA_concatenated_prot.fasta 

  singularity exec /cvmfs/singularity.galaxyproject.org/t/r/trimal:1.4.1--h9f5acd7_7 trimal -in MSA_concatenated_prot.fasta -out trimmed_MSA_concatenated_prot.fasta  -gt 0.6 
fi


if [ ! -f "tree.newick" ]; then
    singularity exec /cvmfs/singularity.galaxyproject.org/i/q/iqtree:2.2.0.3--hb97b32f_0 iqtree2 -s trimmed_MSA_concatenated_prot.fasta -T AUTO --prefix rev_aa -safe
    mv rev_aa.treefile tree.newick
fi




