#!/usr/bin/env Rscript
# Load necessary libraries
suppressMessages(library(DESeq2))

# Read the data
data <- read.csv("combined_eurytemora_counts.tsv",sep="\t")
meta <- read.csv("eurytemora_meta.tsv",sep="\t")

mat <- data[,-1]
rownames(mat) <- data[,1]

# Create DESeq2 dataset
dds <- DESeqDataSetFromMatrix(countData=mat, 
                              colData=meta, 
                              design=~treat)

dds <- DESeq(dds)
res <- results(dds, contrast=c("treat",'F10','not'))
write.csv(res, 'F10_v_not.csv')

res <- results(dds, contrast=c("treat",'ord','not'))
write.csv(res, 'ord_v_not.csv')