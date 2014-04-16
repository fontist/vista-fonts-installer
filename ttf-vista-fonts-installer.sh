#!/bin/bash
# Author: Maxwel Leite
# Website: http://needforbits.tumblr.com/
# Description: Script to install Microsoft Vista TrueType Fonts on Ubuntu distros
# Dependencies: wget, fontforge and cabextract
# Tested: Ubuntu Saucy

output_dir="/usr/share/fonts/truetype/vista"
tmp_dir="/tmp/fonts-vista"

if [[ $EUID -ne 0 ]]; then
    echo -e "You must be a root user!\nTry: sudo ./ttf-vista-fonts-installer.sh" 2>&1
    exit 1
fi

if ! which wget >/dev/null; then
    echo "Error: wget is required to download the file"
    echo "Run the following command to install it:"
    echo "sudo apt-get install wget"
    exit 1
fi

if ! which cabextract >/dev/null; then
    echo "Error: cabextract is required to unpack the files"
    echo "Run the following command to install it:"
    echo "sudo apt-get install cabextract"
    exit 1
fi

if ! which fontforge >/dev/null; then
    echo "Error: fontforge is required to convert TTC files into TTF"
    echo "Run the following command to install it:"
    echo "sudo apt-get install fontforge"
    exit 1
fi

file="$tmp_dir/PowerPointViewer.exe"
mkdir -p "$tmp_dir"
cd "$tmp_dir"
err=0

echo -e "\n:: Downloading PowerPoint Viewer...\n"
wget -O "$file" http://download.microsoft.com/download/c/3/0/c30e1cd2-e56a-4161-9e81-34079ab799a3/PowerPointViewer.exe
if [ $? -ne 0 ]; then
    rm -f "$file"
    echo "Error: Download failed!? Please try again!"
    exit 1
fi
echo -e "Done!"

echo -n ":: Extracting... "
cabextract -t "$file" &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error: Can't extract. Corrupted download!? Please try again!"
    err=1
else
    cabextract -F ppviewer.cab "$file" &> /dev/null
    cabextract -L -F '*.tt?' ppviewer.cab &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Can't extract. Corrupted download!? Please try again!"
        err=1
    else
        echo "Done!"
    fi
fi

if [ $err -ne 1 ]; then
    echo -n ":: Converting 'Cambria Regular' (TTC) to TrueType (TTF)... "
    fontforge -lang=ff -c 'Open("cambria.ttc(Cambria)"); Generate("cambria.ttf"); Close();' &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Can't convert file combria.ttc. Please try again!"
        err=1
    else
        echo "Done!"
    fi
fi

if [ $err -ne 1 ]; then
    echo -n ":: Installing... "
    mkdir -p "$output_dir"
    cp -f "$tmp_dir/"*.ttf "$output_dir"
    echo "Done!"
fi

if [ $err -ne 1 ]; then
	echo -n ":: Clean the font cache... "
	fc-cache -f "$output_dir" &> /dev/null
	echo "Done!"
fi

echo -n ":: Cleanup... "
cd - &> /dev/null
rm -rf "$tmp_dir" &> /dev/null
echo "Done!"
