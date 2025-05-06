#!/bin/bash
#SBATCH -p test # Partition to submit to (comma separated)
#SBATCH -J split_blast # Job name
#SBATCH -n 10 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 30G
#SBATCH -t 0-7:59
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=END 
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=FAIL
# Create the output directory if it doesn't exist

input_file="$1"
output_dir="$2"
mkdir -p "$output_dir"

# AWK script to split the TSV file
awk -F'\t' -v output_dir="$output_dir" '{
    # Extract the value of the first column
    value = $1

    # Construct the output file path
    output_file = output_dir "/" value ".tsv"

    # Append the current line to the corresponding output file
    print >> output_file
}' "$input_file"

echo "Splitting complete. Split files are stored in $output_dir directory."