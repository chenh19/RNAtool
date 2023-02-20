#!/bin/bash

## FastP
[ ! -f fastp ] && wget -q http://opengene.org/fastp/fastp -O fastp
[ ! -d /opt/RNAtool/ ] && sudo mkdir /opt/RNAtool/
sudo cp -f ./fastp /opt/RNAtool/
sudo chmod a+x /opt/RNAtool/fastp
[ ! -f ~/.bashrc] ] && touch ~/.bashrc
if ! grep -q "fastp='/opt/RNAtool/fastp'" ~/.bashrc ; then echo -e "alias fastp='/opt/RNAtool/fastp'" >> ~/.bashrc ; fi
rm -f ./fastp
