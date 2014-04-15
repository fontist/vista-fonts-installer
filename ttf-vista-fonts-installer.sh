#!/bin/bash
# Author: Maxwel Leite
# Website: http://needforbits.tumblr.com/
# Description:
# Simples script to install Microsoft Vista TrueType Fonts on Ubuntu distros
# Dependencies: wget, fontforge, cabextract
# Tested: Ubuntu Saucy

if [[ $EUID -ne 0 ]]; then
    echo -e "You must be a root user!\nTry: sudo ./ttf-vista-fonts-installer.sh" 2>&1
    exit 1
fi

mkdir -p /tmp/fonts-vista && cd /tmp/fonts-vista
wget -c http://download.microsoft.com/download/c/3/0/c30e1cd2-e56a-4161-9e81-34079ab799a3/PowerPointViewer.exe

#todo test if file downloaded is OK
# cabextract -v PowerPointViewer.exe
cabextract -F ppviewer.cab PowerPointViewer.exe
cabextract -L -F '*.tt?' ppviewer.cab

fontforge -lang=ff -c 'Open("cambria.ttc(Cambria)"); Generate("cambria.ttf"); Close();'
mkdir -p /usr/share/fonts/truetype/vista
cp /tmp/fonts-vista/*.ttf /usr/share/fonts/truetype/vista

fc-cache -f /usr/share/fonts/truetype/vista
rm -rf /tmp/fonts-vista
