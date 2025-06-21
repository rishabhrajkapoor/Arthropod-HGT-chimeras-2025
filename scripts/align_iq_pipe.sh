#!/bin/bash
#SBATCH -p shared # Partition to submit to (comma separated)
#SBATCH -J phylopipe # Job name
#SBATCH -n 20 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 25G
#SBATCH -t 00-08:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=FAIL

echo "short_$2"
cd "outputs/phylogenetic_dataset/$1/$2"

# count sequences in your FASTA
NUM_SEQ=$(grep -c '^>' all_sequences.fa)
echo "Found $NUM_SEQ sequences."


if (( NUM_SEQ > 1200 )); then
    singularity exec /cvmfs/singularity.galaxyproject.org/m/u/muscle:5.1--h4ac6f70_3 muscle -super5 all_sequences.fa -output MSA.fasta -threads 20

else
    singularity exec /cvmfs/singularity.galaxyproject.org/m/u/muscle:5.1--h4ac6f70_3 muscle -align all_sequences.fa -output MSA.fasta -threads 20
fi

singularity exec /cvmfs/singularity.galaxyproject.org/t/r/trimal:1.4.1--h9f5acd7_7 trimal -in MSA.fasta -out trimmed_MSA.fasta -gt 0.6 

sbatch "/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/hgt_pipeline_redo_2025/scripts/"iqtree.sh $1 $2