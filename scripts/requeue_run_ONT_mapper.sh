#!/bin/bash
#SBATCH -p serial_requeue
#SBATCH -J coverage
#SBATCH -n 30
#SBATCH -N 1
#SBATCH --mem 30G
#SBATCH -t 02-00:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=END
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=FAIL

set -euo pipefail

mkdir -p "fastq_mapping/$1"
cd "fastq_mapping/$1"

fna_file="$(find "../../ncbi_dataset/data/$2/" -type f -name "*.fna" -print -quit)"
echo "$fna_file"

if [ -z "$fna_file" ] || [ ! -f "$fna_file" ]; then
    echo "ERROR: No .fna file found under ../../ncbi_dataset/data/$2/ (or file missing)" >&2
    exit 1
fi

########################################
# FASTQ DUMP 
########################################
output_file="$1.fastq"


#Check if the output file already exists
if [ ! -f "$output_file" ]; then
    # Run the singularity command
    singularity exec /cvmfs/singularity.galaxyproject.org/s/r/sra-tools:3.1.1--h4304569_2 fastq-dump "$1"
else
    echo "$output_file already exists. Skipping fastq-dump."
fi

########################################
# MINIMAP2 ALIGNMENT 
########################################
output_file="aligned_reads.sam"
tmp_file="${output_file}.tmp"

if [ ! -f "$output_file" ]; then
    rm -f "$tmp_file"
    singularity exec /cvmfs/singularity.galaxyproject.org/m/i/minimap2:2.28--he4a0461_3 \
        minimap2 -ax "$3" "$fna_file" "$1.fastq" > "$tmp_file"
    mv -f "$tmp_file" "$output_file"
else
    echo "$output_file already exists."
fi

########################################
# SAMTOOLS VIEW + SORT 
########################################
output_file="aligned_reads.bam"
tmp_file="${output_file}.tmp"

if [ ! -f "$output_file" ]; then
    rm -f "$tmp_file"
    singularity exec /cvmfs/singularity.galaxyproject.org/s/a/samtools:1.21--h50ea8bc_0 \
        samtools view -Sb aligned_reads.sam | \
    singularity exec /cvmfs/singularity.galaxyproject.org/s/a/samtools:1.21--h50ea8bc_0 \
        samtools sort -o "$tmp_file"
    mv -f "$tmp_file" "$output_file"
else
    echo "$output_file already exists."
fi

########################################
# BAM TO BED 
########################################
output_file="reads.bed"
tmp_file="${output_file}.tmp"

if [ ! -f "$output_file" ]; then
    rm -f "$tmp_file"
    singularity exec /cvmfs/singularity.galaxyproject.org/b/e/bedtools:2.31.1--hf5e1c6e_2 \
        bedtools bamtobed -i aligned_reads.bam > "$tmp_file"
    mv -f "$tmp_file" "$output_file"
else
    echo "$output_file already exists."
fi

########################################
# BEDTOOLS INTERSECT 
########################################
output_file="overlaps.txt"
tmp_file="${output_file}.tmp"

if [ ! -f "$output_file" ]; then
    rm -f "$tmp_file"
    singularity exec /cvmfs/singularity.galaxyproject.org/b/e/bedtools:2.31.1--hf5e1c6e_2 \
        bedtools intersect -a reads.bed \
        -b "../../ncbi_dataset/data/$2/concatenated.bed" \
        -wa -wb > "$tmp_file"
    mv -f "$tmp_file" "$output_file"
else
    echo "$output_file already exists."
fi

########################################
# CLEANUP IF SUCCESSFUL
########################################
if [ -f overlaps.txt ] && [ "$(wc -l < overlaps.txt)" -gt 1 ]; then
    rm -f aligned_reads.bam aligned_reads.sam "$1.fastq"
fi