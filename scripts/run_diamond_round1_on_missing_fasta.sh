#!/bin/bash
#SBATCH -p sapphire # Partition to submit to (comma separated)
#SBATCH -J diamond # Job name
#SBATCH -n 100 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 450G
#SBATCH -t 02-00:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=FAIL
mkdir -p round1_diamond_out

singularity exec /cvmfs/singularity.galaxyproject.org/d/i/diamond:2.0.15--hb97b32f_1 diamond blastp --db /net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/dbs/nr.dmnd --query /net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/hgt_pipeline_redo_2025/outputs/missing_blast_hits_round1.fasta --out /n/netscratch/extavour_lab/Everyone/Rishabh/round1_diamond_out/missing.tsv --outfmt 6 qseqid sseqid stitle staxids sscinames sphylums skingdoms pident length mismatch gapopen qstart qend sstart send evalue bitscore --threads 100 --evalue 10  --very-sensitive -k 30000

