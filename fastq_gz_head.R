# Set the folder containing current R script as working directory
setwd(".")
print(paste("Current working dir:", getwd()))

# check frist few lines in .fastq.gz files
readLines(gzfile("file_path"), n = 50)
