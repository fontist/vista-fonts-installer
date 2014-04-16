#!/bin/bash
# Author: Maxwel Leite
# Website: http://needforbits.tumblr.com/
# Description:
# Simples script to install Microsoft Vista TrueType Fonts on Ubuntu distros
# Dependencies: wget, fontforge, cabextract
# Tested: Ubuntu Saucy

output_dir="/usr/share/fonts/truetype/vista"
tmp_dir="/tmp/fonts-vista"

if [[ $EUID -ne 0 ]]; then
    echo -e "You must be a root user!\nTry: sudo ./ttf-vista-fonts-installer.sh" 2>&1
    exit 1
fi

if ! which wget >/dev/null; then
    echo "Error: wget is required to download the files"
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

file="$tmp_dir/PowerPointViewer.exe"
mkdir -p $tmp_dir

echo -n "Fetching ... "
wget -O "$file" http://download.microsoft.com/download/c/3/0/c30e1cd2-e56a-4161-9e81-34079ab799a3/PowerPointViewer.exe
if [ $? -ne 0 ]; then
    rm -f $file
    echo -e "failed! Download failed!?\nPlease try again!"
    exit 1
fi
echo "done"

#todo test if file downloaded is OK
# cabextract -v PowerPointViewer.exe

echo -n "Extracting ... "
cabextract -t "$file" &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "failed! Can't extract. Corrupted download!?\nPlease try again!"
    rm -f "$tmp_dir/PowerPointViewer.exe"
    exit 1
fi
cabextract -F ppviewer.cab -d $tmp_dir "$tmp_dir/PowerPointViewer.exe" &> /dev/null
cabextract -L -F '*.tt?' -d $tmp_dir ppviewer.cab &> /dev/null
echo "done"

echo -n "Converting 'Cambria Regular' to TrueType... "
cd "$tmp_dir"
fontforge -lang=ff -c 'Open("cambria.ttc(Cambria)"); Generate("cambria.ttf"); Close();' &> /dev/null
echo "done"

echo -n "Installing... "
mkdir -p "$output_dir"
cp "$tmp_dir/*.ttf" "$output_dir"
echo "done"

echo -n "Clean the font cache... "
fc-cache -f $output_dir &> /dev/null
echo "done"

echo -n "Cleanup... "
rm -rf /tmp/fonts-vista &> /dev/null
echo "done"
