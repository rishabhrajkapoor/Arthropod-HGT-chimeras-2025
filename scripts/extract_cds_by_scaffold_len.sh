#!/bin/bash
#SBATCH -p shared # Partition to submit to (comma separated)
#SBATCH -J diamond # Job name
#SBATCH -n 4 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 10G
#SBATCH -t 1-00:00



#written by chatgpt and RK
# Set the input file
cd "/n/netscratch/extavour_lab/Everyone/Rishabh/ncbi_dataset/data/$1/"



# Set the field separator to a newline character
IFS=$'\n'
declare -a targets
# Read each line of the file into an array
while read -r line; do
  # Check if the line contains the string "Mitochondrion"
  if echo "$line" | grep -q "Mitochondrion"; then
    refseq_accession=$(echo "$line" | grep -o '"refseqAccession":"[^"]\+"')
    # Extract the value of the refseqAccession field
    refseq_accession="$(echo "$refseq_accession" | cut -d ':' -f 2 | tr -d '"')"
    targets+=("$refseq_accession")
  fi

  # Check if the line contains the string "length:" followed by a number greater than 100000
  length=$(echo "$line" | grep -o '"length":[0-9]\+')
  length="$(echo "$length" | cut -d ':' -f 2)"
  if [ "$length" -gt 100000 ]; then
    refseq_accession=$(echo "$line" | grep -o '"refseqAccession":"[^"]\+"')
    # Extract the value of the refseqAccession field
    refseq_accession="$(echo "$refseq_accession" | cut -d ':' -f 2 | tr -d '"')"
    
    targets+=("$refseq_accession")
  fi
done < "sequence_report.jsonl"


# Use awk to filter the input file
awk -v targets="${targets[*]}" 'BEGIN {
  split(targets, target_array, " ")
}

# Skip lines starting with "##"
/^##/ {next}

# Process remaining lines
{
  # Extract the first and third items (delimited by tabs)
  first_item=$1
  third_item=$3
  output=$9
  
 
 
  
  # Check if the third item is equal to "CDS"
  if (third_item == "CDS") {
    found=0
    for (i in target_array) {
      if (first_item == target_array[i]) {
        found=1
        break
      }
    }
    
    if (found == 1) {
      print $9 >>"outs.txt"
    }
  }
}' "genomic.gff"

# Store the file name in a variable
file=outs.txt

#extract cds accessions
sed 's/.*ID=cds-\([^;]*\);.*/\1/' $file > temp.txt

# Replace the original file with the modified version
mv temp.txt $file

##filter out the protein fastas
singularity exec /cvmfs/singularity.galaxyproject.org/s/e/seqkit:2.9.0--h9ee0642_0 seqkit grep -f outs.txt protein.faa -o filtered_sequences.faa