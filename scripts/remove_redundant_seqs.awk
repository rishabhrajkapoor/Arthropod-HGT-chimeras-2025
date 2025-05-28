#!/usr/bin/awk -f

BEGIN { FS = "\n"; RS = ">" }  # Set the record separator to ">"

{
    if (NF > 1) {  # Skip empty lines
        seq = $2  # Store the sequence in a variable
        gsub("\n", "", seq)  # Remove any newline characters
        if (!(seq in sequences)) {  # If the sequence hasn't been seen yet
            sequences[seq] = $1  # Add the sequence to the hash table with the header as the value
            print ">"$0  # Print the fasta header and sequence
        } else {
            print "Redundant sequence removed: " $1 > "/dev/stderr"  # Output the header of the redundant sequence to stderr
            print "Replacement sequence: " sequences[seq] > "/dev/stderr"  # Output the header of the replacement sequence to stderr
        }
    }
}