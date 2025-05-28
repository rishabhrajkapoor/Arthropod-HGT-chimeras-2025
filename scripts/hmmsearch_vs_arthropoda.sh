#!/bin/bash
#SBATCH -J hmmsearch_vs_arthropoda
#SBATCH -p sapphire
#SBATCH -c 2
#SBATCH -t 01-00:00
#SBATCH --mem 100G
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=FAIL


singularity exec /cvmfs/singularity.galaxyproject.org/h/m/hmmer:3.3.2--he1b5a44_0 hmmsearch -E 1e-2 --cpu 2 --noali --domtblout "hmmsearch_v_arthropod_db.domtblout" "all_concatenated.hmm"  "outputs/all_arthropod_concatenated_proteins.fa"