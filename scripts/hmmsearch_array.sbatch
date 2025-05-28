#!/bin/bash
#SBATCH -J hmmsearch_v_nr
#SBATCH -p sapphire
#SBATCH -c 2
#SBATCH -t 00-16:00
#SBATCH --mem 300G
#SBATCH -o hmmsearch_%A_%a.out
#SBATCH -e hmmsearch_%A_%a.err
#SBATCH --array=11-118

singularity exec /cvmfs/singularity.galaxyproject.org/h/m/hmmer:3.3.2--he1b5a44_0 hmmsearch -E 1e-2 --cpu 2 --noali --domtblout "concatenated_hmmsearch_arthropoda_outputs/${SLURM_ARRAY_TASK_ID}.domtblout" "concatenated_hmms/${SLURM_ARRAY_TASK_ID}.hmm"  "/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/dbs/nr.fasta"