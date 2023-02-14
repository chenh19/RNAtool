#!/bin/bash

# install fastqc
sudo apt-get update && sudo apt-get install fastqc -y

# run fastqc in parallel
cd ~/Developing/
[ ! -d ./1_HC_fastqc/ ] && mkdir ./1_HC_fastqc/
fastqc --threads 16 ./0.PIE-seq_raw/FastQ/*.fastq.gz --outdir=./1_HC_fastqc/
