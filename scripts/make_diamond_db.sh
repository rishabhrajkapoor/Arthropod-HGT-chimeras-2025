#!/bin/bash
#SBATCH -p test # Partition to submit to (comma separated)
#SBATCH -J diamond_db # Job name
#SBATCH -n 50 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 300G
#SBATCH -t 00-08:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=END 
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=FAIL

singularity exec /cvmfs/singularity.galaxyproject.org/d/i/diamond:2.0.15--hb97b32f_1 diamond makedb --in '/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/dbs/nr.fasta' --db '/n/netscratch/extavour_lab/Everyone/Rishabh/dbs/nr' --taxonmap '/n/netscratch/extavour_lab/Everyone/Rishabh/dbs/prot.accession2taxid.FULL.gz' --taxonnodes '/n/netscratch/extavour_lab/Everyone/Rishabh/dbs/nodes.dmp' --taxonnames '/n/netscratch/extavour_lab/Everyone/Rishabh/dbs/names.dmp' --threads 50