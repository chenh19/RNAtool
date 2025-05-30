#!/bin/bash

output_file="read_counts.csv"
> "$output_file"
for f in *.fastq *.fastq.gz; do
  [[ -f "$f" ]] || continue
  if [[ "$f" == *.gz ]]; then
    count=$(gzip -dc "$f" | awk 'END {print NR/4}')
  else
    count=$(awk 'END {print NR/4}' "$f")
  fi
  echo "$f: $count reads"
  echo "$f, $count" >> "$output_file"
done
