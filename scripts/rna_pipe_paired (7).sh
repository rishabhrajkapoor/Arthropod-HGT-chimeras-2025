#!/bin/bash
#SBATCH -p serial_requeue # Partition to submit to (comma separated)
#SBATCH -J rnaseq # Job name
#SBATCH -n 64 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 50G
#SBATCH -t 0-06:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=END 
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=FAIL
# Create the output directory if it doesn't exist


direct='/n/netscratch/extavour_lab/Everyone/Rishabh'

mkdir -p "$direct"/RNA_seq_results/"$1"
cd "$direct"/RNA_seq_results/"$1"


#Check if neither "$1_1.fastq" nor "$1_2.fastq" exist
if [[ ! -f "$1"_1.fastq && ! -f "$1"_2.fastq ]]; then
    # If they don't exist, run both fasterq-dump and trim-galore
    singularity exec /cvmfs/singularity.galaxyproject.org/s/r/sra-tools:3.1.0--h9f5acd7_0 fasterq-dump "$1"
    singularity exec /cvmfs/singularity.galaxyproject.org/t/r/trim-galore:0.6.9--hdfd78af_0 trim_galore --paired "$1"_1.fastq "$1"_2.fastq -j 10
fi

singularity exec /cvmfs/singularity.galaxyproject.org/s/t/star:2.7.9a--h9ee0642_0 STAR \
    --runThreadN 64 \
    --genomeDir "$direct/ncbi_dataset/data/$2/STAR" \
    --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix "$1" \
    --readFilesIn "$1"_1_val_1.fq "$1"_2_val_2.fq
    

singularity exec /cvmfs/singularity.galaxyproject.org/s/u/subread:2.0.6--he4a0461_0 featureCounts   -g "gene" -T 64 -t 'exon' -o "featureCounts"  -a "$direct/ncbi_dataset/data/$2/genomic.gff" -p "$1"Aligned.sortedByCoord.out.bam


python3 "/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/IF_project_iteration2/RNA_seq_scripts/split_featureCounts.py" $1
python3 "/net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/IF_project_iteration2/RNA_seq_scripts/tpm_norm_coding_only.py" $1 $2

if [ -f "coding_only_expr.tpm.tsv" ]; then
  rm -r *$1*
fi


# cp -r "$direct"/RNA_seq_results/"$x" /net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/IF_project_iteration2/RNA_seq_results/"$x"