#!/bin/bash
#This script installs STAR for RNA-seq data processing.

sudo echo ""
[ ! -f STAR.zip ] && wget -q https://github.com/alexdobin/STAR/releases/download/2.7.10b/STAR_2.7.10b.zip -O STAR.zip #_to_be_updated
unzip -o -q STAR.zip && sleep 1 && rm -f STAR.zip && sleep 1
[ ! -d /opt/RNAtool/ ] && sudo mkdir /opt/RNAtool/
sudo cp -f ./STAR*/Linux_x86_64/* /opt/RNAtool/ && sleep 1
rm -rf ./STAR*/
[ ! -f ~/.bashrc] ] && touch ~/.bashrc
if ! grep -q "alias STAR='/opt/RNAtool/STAR'" ~/.bashrc ; then echo -e "alias STAR='/opt/RNAtool/STAR'" >> ~/.bashrc ; fi
if ! grep -q "alias STARlong='/opt/RNAtool/STARlong'" ~/.bashrc ; then echo -e "alias STARlong='/opt/RNAtool/STARlong'" >> ~/.bashrc ; fi
