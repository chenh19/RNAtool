#!/bin/bash


## JACUSA2
[ ! -f jacusa2.jar ] && wget -q https://github.com/dieterich-lab/JACUSA2/releases/download/v2.0.2-RC/JACUSA_v2.0.2-RC.jar -O jacusa2.jar
[ ! -d /opt/RNAtool/ ] && sudo mkdir /opt/RNAtool/
sudo cp -f ./jacusa2.jar /opt/RNAtool/
[ ! -f ~/.bashrc] ] && touch ~/.bashrc
if ! grep -q "jacusa2='java -jar /opt/RNAtool/jacusa2.jar'" ~/.bashrc ; then echo -e "alias jacusa2='java -jar /opt/RNAtool/jacusa2.jar'" >> ~/.bashrc ; fi
rm -f ./jacusa2.jar


## JACUSA2helper
[ ! -f BSgenome.Hsapiens.NCBI.GRCh38_1.3.1000.tar.gz ] && wget https://bioconductor.org/packages/3.16/data/annotation/src/contrib/BSgenome.Hsapiens.NCBI.GRCh38_1.3.1000.tar.gz
[ ! -f JACUSA2helper_1.9.9.9600.tar.gz ] && wget -q https://github.com/dieterich-lab/JACUSA2helper/releases/download/v1.99-9600/JACUSA2helper_1.9.9.9600.tar.gz
echo -e "devtools::install_local('BSgenome.Hsapiens.NCBI.GRCh38_1.3.1000.tar.gz', force = TRUE)\ndevtools::install_local('JACUSA2helper_1.9.9.9600.tar.gz', dependencies = TRUE, build_vignettes = TRUE, force = TRUE)" > ./jacusa2helper.R
sudo Rscript ./jacusa2helper.R
rm -f ./BSgenome.Hsapiens.NCBI.GRCh38_1.3.1000.tar.gz ./JACUSA2helper_1.9.9.9600.tar.gz ./jacusa2helper.R
