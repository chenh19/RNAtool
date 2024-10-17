# check frist few lines in .fastq.gz files
readLines(gzfile("file_path"), n = 50)