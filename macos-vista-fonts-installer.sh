#!/bin/bash
# Author: Maxwel Leite
# Adapted to macOS by Ronald Tse
# Website: http://needforbits.wordpress.com/
# Description: Script to install Microsoft Vista TrueType Fonts (TTF) aka Microsoft’s ClearType fonts on Ubuntu distros
#              Microsoft added a group of new "ClearType Fonts" to Windows with Windows Vista and Office 2007.
#              These fonts are named Constantia, Corbel, Calibri, Cambria (and Cambria Math), Candara, and Consolas.
#              Calibri became the default font on Microsoft Word 2007, and it’s still the default font on Word 2016 today.
# Dependencies: wget, fontforge and cabextract
# Note: Microsoft no longer provides the PowerPoint Viewer 2007 (v12.0.4518.1014) or any version anymore for download
# Tested: macOS 10.15.2

set -e # Exit with nonzero exit code if anything fails

readonly __progname=macos-vista-fonts-installer
readonly PPV_PATH=https://web.archive.org/web/20171225132744/http://download.microsoft.com/download/E/6/7/E675FFFC-2A6D-4AB0-B3EB-27C9F8C8F696/PowerPointViewer.exe

MS_FONT_PATH=${1:-~/Library/Fonts/Microsoft}
temp_dir=$(mktemp -d)

errx() {
  echo -e "[${__progname}] $*" >&2
  exit 1
}

process_font() {
  fontfile="$1"
  dest_dir="$2"

  if [ "$fontfile" == "calibri.ttf" ]; then
    mv "$fontfile" $dest_dir/Calibri.ttf
  elif [ "$fontfile" == "calibrib.ttf" ]; then
    mv "$fontfile" $dest_dir/Calibri\ Bold.ttf
  elif [ "$fontfile" == "calibrii.ttf" ]; then
    mv "$fontfile" $dest_dir/Calibri\ Italic.ttf
  elif [ "$fontfile" == "calibriz.ttf" ]; then
    mv "$fontfile" $dest_dir/Calibri\ Bold\ Italic.ttf
  elif [ "$fontfile" == "cambria.ttc" ]; then

    # If you need the Cambria and Cambria Math (regular) font, you'll need to convert it to TTF because the font is available
    # as a TrueType Collection (TTC) and unless you convert it, you won't be able to use it in LibreOffice for instance.

    # dest_dir=.
    # fontfile="cambria.ttc"
    for font in "Cambria" "Cambria Math"; do
      echo ":: Converting '${font}' (TTC - TrueType Collection) to TrueType (TTF)... " >&2
      fontforge -lang=ff -c "Open(\"${fontfile}(${font})\"); Generate(\"${font}.ttf\"); Close();" || \
        errx "Error: Can't convert ${font} from '${fontfile}'."
      mv "${font}.ttf" $dest_dir/
    done

  elif [ "$fontfile" == "cambriab.ttf" ]; then
    mv "$fontfile" $dest_dir/Cambria\ Bold.ttf
  elif [ "$fontfile" == "cambriai.ttf" ]; then
    mv "$fontfile" $dest_dir/Cambria\ Italic.ttf
  elif [ "$fontfile" == "cambriaz.ttf" ]; then
    mv "$fontfile" $dest_dir/Cambria\ Bold\ Italic.ttf
  elif [ "$fontfile" == "candara.ttf" ]; then
    mv "$fontfile" $dest_dir/Candara.ttf
  elif [ "$fontfile" == "candarab.ttf" ]; then
    mv "$fontfile" $dest_dir/Candara\ Bold.ttf
  elif [ "$fontfile" == "candarai.ttf" ]; then
    mv "$fontfile" $dest_dir/Candara\ Italic.ttf
  elif [ "$fontfile" == "candaraz.ttf" ]; then
    mv "$fontfile" $dest_dir/Candara\ Bold\ Italic.ttf
  elif [ "$fontfile" == "consola.ttf" ]; then
    mv "$fontfile" $dest_dir/Consola.ttf
  elif [ "$fontfile" == "consolab.ttf" ]; then
    mv "$fontfile" $dest_dir/Consola\ Bold.ttf
  elif [ "$fontfile" == "consolai.ttf" ]; then
    mv "$fontfile" $dest_dir/Consola\ Italic.ttf
  elif [ "$fontfile" == "consolaz.ttf" ]; then
    mv "$fontfile" $dest_dir/Consola\ Bold\ Italic.ttf
  elif [ "$fontfile" == "constan.ttf" ]; then
    mv "$fontfile" $dest_dir/Constan.ttf
  elif [ "$fontfile" == "constanb.ttf" ]; then
    mv "$fontfile" $dest_dir/Constan\ Bold.ttf
  elif [ "$fontfile" == "constani.ttf" ]; then
    mv "$fontfile" $dest_dir/Constan\ Italic.ttf
  elif [ "$fontfile" == "constanz.ttf" ]; then
    mv "$fontfile" $dest_dir/Constan\ Bold\ Italic.ttf
  elif [ "$fontfile" == "corbel.ttf" ]; then
    mv "$fontfile" $dest_dir/Corbel.ttf
  elif [ "$fontfile" == "corbelb.ttf" ]; then
    mv "$fontfile" $dest_dir/Corbel\ Bold.ttf
  elif [ "$fontfile" == "corbeli.ttf" ]; then
    mv "$fontfile" $dest_dir/Corbel\ Italic.ttf
  elif [ "$fontfile" == "corbelz.ttf" ]; then
    mv "$fontfile" $dest_dir/Corbel\ Bold\ Italic.ttf

  elif [ "$fontfile" == "meiryo.ttc" ]; then

    for font in "Meiryo" "Meiryo Italic" "Meiryo UI" "Meiryo UI Italic"; do
      echo ":: Converting '${font}' (TTC - TrueType Collection) to TrueType (TTF)... " >&2
      fontforge -lang=ff -c "Open(\"${fontfile}(${font})\"); Generate(\"${font}.ttf\"); Close();" || \
        errx "Error: Can't convert ${font} from '${fontfile}'."
      mv "${font}.ttf" $dest_dir/
    done

  elif [ "$fontfile" == "meiryob.ttc" ]; then

    for font in "Meiryo Bold" "Meiryo Bold Italic" "Meiryo UI Bold" "Meiryo UI Bold Italic"; do
      echo ":: Converting '${font}' (TTC - TrueType Collection) to TrueType (TTF)... " >&2
      fontforge -lang=ff -c "Open(\"${fontfile}(${font})\"); Generate(\"${font}.ttf\"); Close();" || \
        errx "Error: Can't convert ${font} from '${fontfile}'."
      mv "${font}.ttf" $dest_dir/
    done

  fi

  echo "Processing $fontfile complete." >&2
}


main() {
  mkdir -p ${MS_FONT_PATH} || \
    errx "Unable to write to ${MS_FONT_PATH}."

  MS_FONT_PATH=$(cd "$(dirname "$MS_FONT_PATH")"; pwd)/$(basename "$MS_FONT_PATH")

  echo "Installing fonts to ${MS_FONT_PATH}" >&2


  # if [[ $EUID -ne 0 ]]; then
  #   errx "You must be a root user. Try: `sudo ./${__progname}.sh`"
  # fi

  if ! which curl >/dev/null; then
    errx "curl is required to download the file"
  fi

  if ! which cabextract >/dev/null; then
    errx "cabextract is required to unpack the files. Try: `brew install cabextract`"
  fi

  if ! which fontforge >/dev/null; then
    errx "fontforge is required to convert TTC files into TTF. Try: `brew install fontforge`"
  fi

  pushd $temp_dir
  file=$(basename ${PPV_PATH})

  echo -e "\n:: Downloading ${file} from ${PPV_PATH}..."
  curl -L ${PPV_PATH} -o ${file} || \
    errx "\nError: Download failed.\n"

  echo -e "Done!\n"

  echo -n ":: Extracting fonts from ${file}... "

  cabextract -t "$file" || \
    errx "Error: Can't extract from ${file}. Corrupted download?"

  cabextract -F ppviewer.cab "$file" || \
    errx "Error: Can't extract 'ppviewer.cab' from '${file}'. Corrupted download?"

  cabextract -L -F '*.tt?' ppviewer.cab || \
    errx "Error: Can't extract '*.tt?' from 'ppviewer.cab'. Corrupted download?"

  echo "Done!" >&2

  echo -n ":: Installing... " >&2

  for fontfile in $(find . -name '*.tt*' -type f -depth 1 -exec basename \{} \;); do
    process_font $fontfile $MS_FONT_PATH|| \
      errx "Process font $fontfile failed, exiting.".
  done

  echo "Done!" >&2

  # if [ $err -ne 1 ]; then
  #   echo -n ":: Clean the font cache... "
  #   fc-cache -f "$output_dir" &> /dev/null
  #   echo "Done!"
  # fi

  echo -e "\nCongratulations! Installation successful!!\n" >&2
}

main $@

# echo -n ":: Cleanup... "
# cd - &> /dev/null
rm -rf "$temp_dir" &> /dev/null

exit $?
