#!/bin/bash
#SBATCH -p shared # Partition to submit to (comma separated)
#SBATCH -J download_tax # Job name
#SBATCH -n 1 # Number of cores
#SBATCH -N 1 # Ensure that all cores are on one machine
#SBATCH --mem 4G
#SBATCH -t 0-06:00
#SBATCH --mail-user=rkapoor@g.harvard.edu
#SBATCH --mail-type=END 
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=FAIL

# Destination directory for downloaded files
DEST_DIR="net/bos-nfsisilon/ifs/rc_labs/extavour_lab/rkapoor/dbs/tax_db"

# URLs for files to download
ACCESSION_URL="ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.FULL.gz"
NODES_URL="ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz"

mkdir -p "$DEST_DIR"
# Change to destination directory
cd "$DEST_DIR"


# Download accession2taxid file and save it to destination directory
echo "Downloading protein accession2taxid file from $ACCESSION_URL..."
curl -o prot.accession2taxid.gz "$ACCESSION_URL"

NODES_URL="ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz"
# # Download taxonomy dump file and extract required files
echo "Downloading and extracting taxonomy dump files from $NODES_URL..."
curl -o taxdump.tar.gz "$NODES_URL"
tar -xzf taxdump.tar.gz names.dmp nodes.dmp

 
echo "Download complete."
