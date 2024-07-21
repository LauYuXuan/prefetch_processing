#!/bin/bash

# Check if the required arguments are provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 <srr_list_file> <sra_file_path> <fastq_output_path>"
  exit 1
fi

# Assign the arguments to variables
srr_list_file="$1"
sra_file_path="$2"
fastq_output_path="$3"

# Read the SRR list file line by line
while read -r srr_id; do
  # Check if the FASTQ output directory for the current SRR ID is empty
  if [ -z "$(ls -A "$fastq_output_path/$srr_id" 2>/dev/null)" ]; then
    # Find the corresponding SRA directory in the sra_file_path directory
    sra_dir=$(find "$sra_file_path" -maxdepth 1 -type d -name "$srr_id")

    # Check if the SRA directory exists
    if [ -d "$sra_dir" ]; then
      # Change to the SRA directory
      cd "$sra_dir"

      # Find the SRA file
      sra_file=$(find . -maxdepth 1 -name "*.sra")

      # Check if the SRA file exists
      if [ -f "$sra_file" ]; then
        # Create the output directory for the FASTQ files if it doesn't exist
        mkdir -p "$fastq_output_path/$srr_id"

        # Run fastq-dump to convert the SRA file to FASTQ format
        fastq-dump --outdir "$fastq_output_path/$srr_id" --gzip --split-files "$sra_file"

        echo "FASTQ conversion completed for $srr_id"
      else
        echo "SRA file not found for $srr_id"
      fi

      # Change back to the original directory
      cd - >/dev/null
    else
      echo "SRA directory not found for $srr_id"
    fi
  else
    echo "FASTQ files already exist for $srr_id. Skipping FASTQ conversion."
  fi
done < "$srr_list_file"