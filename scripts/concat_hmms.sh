#!/bin/bash
#written by chatGPT and RK
# Check if the number of command-line arguments is correct
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <output_file> <file1>~<file2>~<file3>..."
  exit 1
fi

# Split the first command-line argument as the output file name
output_file=$1

# Split the second command-line argument as the tilde delimited list of files
IFS='~' read -ra files <<< "$2"

# Concatenate files without separator
cat "${files[@]}" > "$output_file"

echo "Files concatenated successfully. Result saved in $output_file."

