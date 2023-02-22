#!/bin/bash

## PICARD
sudo echo ""
[ ! -f picard.jar ] && wget -q https://github.com/broadinstitute/picard/releases/download/2.27.5/picard.jar -O picard.jar
[ ! -d /opt/RNAtool/ ] && sudo mkdir /opt/RNAtool/
sudo cp -f ./picard.jar /opt/RNAtool/
[ ! -f ~/.bashrc] ] && touch ~/.bashrc
if ! grep -q "picard='java -jar /opt/RNAtool/picard.jar'" ~/.bashrc ; then echo -e "alias picard='java -jar /opt/RNAtool/picard.jar'" >> ~/.bashrc ; fi
rm -f ./picard.jar
