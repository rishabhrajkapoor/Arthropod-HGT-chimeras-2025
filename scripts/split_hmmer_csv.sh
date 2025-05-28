#!/bin/bash
awk -F ' ' -v OFS='\t' '!/^#/ {
    for (i = 1; i <= 22; i++) {
        if ($i != "") {
            printf "%s%s", $i, (i < 22) ? OFS : "";
        }
    }
    
    if (NF > 22) {
        printf "%s", OFS;
        for (i = 23; i <= NF; i++) {
            if ($i != "") {
                printf "%s%s", $i, (i < NF) ? " " : "";
            }
        }
    }
    
    printf "\n";
}' $1 |
awk -F '\t' -v OFS='\t' '{
    if ($NF ~ /\[.*\]/) {
        match($NF, /\[([^]]+)\]/, matchArr);  # Extract the text within square brackets
        newColumn = matchArr[1];  # Store the extracted text in a variable
    } else {
        newColumn = "";  # Empty value for rows without square brackets
    }

    print $0, newColumn;  # Output the original row with the new column
}' |
awk -F '\t' -v outdir="$2" '
NR > 1 {
    filename = outdir "/" $4 ".tsv";
    print >> filename;
}'
