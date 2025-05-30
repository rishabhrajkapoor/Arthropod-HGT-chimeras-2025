#!/bin/bash
#SBATCH -p test # Partition to submit to (comma separated)
#SBATCH -J diamond # Job name
#SBATCH -n 100 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 450G
#SBATCH -t 00-11:59
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=END 
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=FAIL

singularity exec /cvmfs/singularity.galaxyproject.org/d/i/diamond:2.0.15--hb97b32f_1 diamond blastp --db /net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/dbs/nr.dmnd --query outputs/all_secondary_chimeras.fa --out all_secondary_chimeras_out --outfmt 6 qseqid sseqid stitle staxids sscinames sphylums skingdoms pident length mismatch gapopen qstart qend sstart send evalue bitscore --threads 100 --evalue 10  --very-sensitive -k 30000

# sh scripts/split_blast_table.sh 'all_secondary_chimeras_out' 'outputs/secondary_chimera_interval_blast_results'