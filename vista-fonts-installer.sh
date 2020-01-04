#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

readonly __progname=macos-vista-fonts-installer
readonly PPV_PATH=https://web.archive.org/web/20171225132744/http://download.microsoft.com/download/E/6/7/E675FFFC-2A6D-4AB0-B3EB-27C9F8C8F696/PowerPointViewer.exe

CONVERT_TTF=${CONVERT_TTF:-}

# Derived from: https://github.com/rnpgp/rnp/blob/master/ci/utils.inc.sh
get_os() {
  local ostype=$(echo $OSTYPE | tr '[:upper:]' '[:lower:]')
  if [ -z "$ostype" ]; then
    ostype=$(uname | tr '[:upper:]' '[:lower:]')
  fi

  case $ostype in
    freebsd*) echo "freebsd" ;;
    netbsd*) echo "netbsd" ;;
    openbsd*) echo "openbsd" ;;
    darwin*) echo "macos" ;;
    linux*) echo "linux" ;;
    cygwin*) echo "cygwin" ;;
    *) echo "unknown"; exit 1 ;;
  esac
}

get_linux_dist() {
  if [ -f /etc/os-release ]; then
    sh -c '. /etc/os-release && echo $ID'
  elif type lsb_release >/dev/null 2>&1; then
    lsb_release -si | tr '[:upper:]' '[:lower:]'
  fi
}

temp_dir=$(mktemp -d)

errx() {
  echo -e "[${__progname}] Error: $*" >&2
  exit 1
}

process_font_ubuntu() {
  fontfile="$1"
  dest_dir="$2"
  destname="$fontfile"

  if [[ -n "${CONVERT_TTF}" ]]; then

    if [ "$fontfile" == "cambria.ttc" ]; then

      # If you need the Cambria and Cambria Math (regular) font, you'll need to convert it to TTF because the font is available
      # as a TrueType Collection (TTC) and unless you convert it, you won't be able to use it in LibreOffice for instance.

      for font in "Cambria" "Cambria Math"; do
        echo ":: Converting '${font}' (TTC - TrueType Collection) to TrueType (TTF)... " >&2

        if [ "${font}" == "Cambria" ]; then
          destname="cambria.ttf"
        else
          destname="cambriamath.ttf"
        fi

        fontforge -lang=ff -c "Open(\"${fontfile}(${font})\"); Generate(\"${destname}\"); Close();" || \
          errx "Can't convert ${destname} from '${fontfile}'."
        mv -f "${destname}" "$dest_dir/${destname}"
      done
      return

    elif [ "$fontfile" == "meiryo.ttc" ]; then

      for font in "Meiryo" "Meiryo Italic" "Meiryo UI" "Meiryo UI Italic"; do
        echo ":: Converting '${font}' (TTC - TrueType Collection) to TrueType (TTF)... " >&2

        if [ "${font}" == "Meiryo" ]; then
          destname="meiryo.ttf"
        elif [ "${font}" == "Meiryo Italic" ]; then
          destname="meiryoi.ttf"
        elif [ "${font}" == "Meiryo UI" ]; then
          destname="meiryoui.ttf"
        elif [ "${font}" == "Meiryo UI Italic" ]; then
          destname="meiryouii.ttf"
        fi

        fontforge -lang=ff -c "Open(\"${fontfile}(${font})\"); Generate(\"${destname}\"); Close();" || \
          errx "Can't convert ${destname} from '${fontfile}'."
        mv -f "${destname}" "$dest_dir/${destname}"
      done
      return


    elif [ "$fontfile" == "meiryob.ttc" ]; then

      for font in "Meiryo Bold" "Meiryo Bold Italic" "Meiryo UI Bold" "Meiryo UI Bold Italic"; do
        echo ":: Converting '${font}' (TTC - TrueType Collection) to TrueType (TTF)... " >&2

        if [ "${font}" == "Meiryo Bold" ]; then
          destname="meiryob.ttf"
        elif [ "${font}" == "Meiryo Bold Italic" ]; then
          destname="meiryoz.ttf"
        elif [ "${font}" == "Meiryo UI Bold" ]; then
          destname="meiryouib.ttf"
        elif [ "${font}" == "Meiryo UI Bold Italic" ]; then
          destname="meiryouiz.ttf"
        fi

        fontforge -lang=ff -c "Open(\"${fontfile}(${font})\"); Generate(\"${destname}\"); Close();" || \
          errx "Can't convert ${destname} from '${fontfile}'."
        mv -f "${destname}" "$dest_dir/${destname}"
      done
      return
    fi

  fi

  mv -f "$destname" "$dest_dir/" || \
    errx "Cant move $destname into $dest_dir"

  echo "Processing $fontfile complete." >&2
}

process_font_macos() {
  fontfile="$1"
  dest_dir="$2"
  destname="$fontfile"

  if [[ -n "${CONVERT_TTF}" ]]; then

    if [ "$fontfile" == "cambria.ttc" ]; then

      for font in "Cambria" "Cambria Math"; do
        destname="${font}.ttf"
        echo ":: Converting '${font}' (TTC - TrueType Collection) to TrueType (TTF)... " >&2
        fontforge -lang=ff -c "Open(\"${fontfile}(${font})\"); Generate(\"${destname}\"); Close();" || \
          errx "Can't convert '${destname}' from '${fontfile}'."
        mv -f "${destname}" "$dest_dir/"
      done

      return

    elif [ "$fontfile" == "meiryo.ttc" ]; then

      for font in "Meiryo" "Meiryo Italic" "Meiryo UI" "Meiryo UI Italic"; do
        destname="${font}.ttf"
        echo ":: Converting '${font}' (TTC - TrueType Collection) to TrueType (TTF)... " >&2
        fontforge -lang=ff -c "Open(\"${fontfile}(${font})\"); Generate(\"${destname}\"); Close();" || \
          errx "Can't convert '${destname}' from '${fontfile}'."
        mv -f "${destname}" "$dest_dir/"
      done

      return

    elif [ "$fontfile" == "meiryob.ttc" ]; then

      for font in "Meiryo Bold" "Meiryo Bold Italic" "Meiryo UI Bold" "Meiryo UI Bold Italic"; do
        destname="${font}.ttf"
        echo ":: Converting '${font}' (TTC - TrueType Collection) to TrueType (TTF)... " >&2
        fontforge -lang=ff -c "Open(\"${fontfile}(${font})\"); Generate(\"${destname}\"); Close();" || \
          errx "Can't convert '${destname}' from '${fontfile}'."
        mv -f "${destname}" "$dest_dir/"
      done

      return
    fi
  fi

  if [ "$fontfile" == "calibri.ttf" ]; then
    destname="Calibri.ttf"
  elif [ "$fontfile" == "calibrib.ttf" ]; then
    destname="Calibri Bold.ttf"
  elif [ "$fontfile" == "calibrii.ttf" ]; then
    destname="Calibri Italic.ttf"
  elif [ "$fontfile" == "calibriz.ttf" ]; then
    destname="Calibri Bold Italic.ttf"
  elif [ "$fontfile" == "cambriab.ttf" ]; then
    destname="Cambria Bold.ttf"
  elif [ "$fontfile" == "cambriai.ttf" ]; then
    destname="Cambria Italic.ttf"
  elif [ "$fontfile" == "cambriaz.ttf" ]; then
    destname="Cambria Bold Italic.ttf"
  elif [ "$fontfile" == "candara.ttf" ]; then
    destname="Candara.ttf"
  elif [ "$fontfile" == "candarab.ttf" ]; then
    destname="Candara Bold.ttf"
  elif [ "$fontfile" == "candarai.ttf" ]; then
    destname="Candara Italic.ttf"
  elif [ "$fontfile" == "candaraz.ttf" ]; then
    destname="Candara Bold Italic.ttf"
  elif [ "$fontfile" == "consola.ttf" ]; then
    destname="Consola.ttf"
  elif [ "$fontfile" == "consolab.ttf" ]; then
    destname="Consola Bold.ttf"
  elif [ "$fontfile" == "consolai.ttf" ]; then
    destname="Consola Italic.ttf"
  elif [ "$fontfile" == "consolaz.ttf" ]; then
    destname="Consola Bold Italic.ttf"
  elif [ "$fontfile" == "constan.ttf" ]; then
    destname="Constantia.ttf"
  elif [ "$fontfile" == "constanb.ttf" ]; then
    destname="Constantia Bold.ttf"
  elif [ "$fontfile" == "constani.ttf" ]; then
    destname="Constantia Italic.ttf"
  elif [ "$fontfile" == "constanz.ttf" ]; then
    destname="Constantia Bold Italic.ttf"
  elif [ "$fontfile" == "corbel.ttf" ]; then
    destname="Corbel.ttf"
  elif [ "$fontfile" == "corbelb.ttf" ]; then
    destname="Corbel Bold.ttf"
  elif [ "$fontfile" == "corbeli.ttf" ]; then
    destname="Corbel Italic.ttf"
  elif [ "$fontfile" == "corbelz.ttf" ]; then
    destname="Corbel Bold Italic.ttf"
  fi

  mv -f "$fontfile" "$dest_dir/$destname" || \
    errx "Can't move $fontfile into \"$dest_dir/$destname\"; PWD($(pwd))"

  echo "Processing $fontfile complete." >&2
}


main() {
  platform=$(get_os)

  if [ "${platform}" == "macos" ]; then
    echo "Detected platform: macOS" >&2
  elif [ "${platform}" == "linux" ]; then
    if [ "$(get_linux_dist)" == "ubuntu" ]; then
      echo "Detected platform: ubuntu" >&2
      platform="ubuntu"
    else
      errx "Linux distribution $(get_linux_dist) is not supported. Please contribute a fix!"
    fi
  else
    errx "platform ${platform} is not supported. Please contribute a fix!"
  fi

  MS_FONT_PATH=${1:-$MS_FONT_PATH}
  if [ "${MS_FONT_PATH}" == "" ]; then
    case ${platform} in
      macos*) MS_FONT_PATH="~/Library/Fonts/Microsoft" ;;
      ubuntu*) MS_FONT_PATH="/usr/share/fonts/truetype/vista" ;;
      # *) ...; exit 1 ;;
    esac
  fi

  [[ -d ${MS_FONT_PATH} ]] || \
    mkdir -p ${MS_FONT_PATH} || \
      errx "Unable to write to ${MS_FONT_PATH}."

  # Take the absolute path
  MS_FONT_PATH="$(cd ${MS_FONT_PATH}; pwd)"

  # echo "$(cd $(dirname $MS_FONT_PATH))"
  # MS_FONT_PATH=$(cd "$(dirname "$MS_FONT_PATH")"; pwd)/$(basename "$MS_FONT_PATH")


  echo "Installing fonts to ${MS_FONT_PATH}" >&2

  # if [[ $EUID -ne 0 ]]; then
  #   errx "You must be a root user. Try: `sudo ./${__progname}.sh`"
  # fi

  if ! which curl >/dev/null; then
    errx "curl is required to download the file"
  fi

  if ! which cabextract >/dev/null; then
    case ${platform} in
      macos*) errx "cabextract is required to unpack the files. Try: 'brew install cabextract'" ;;
      ubuntu*) errx "cabextract is required to unpack the files. Try: 'sudo apt-get install -y cabextract'" ;;
    esac
  fi

  if [[ -n "${CONVERT_TTF}" ]]; then
    if [ ! $(which fontforge) ]; then
      case ${platform} in
        macos*) errx "fontforge is required to convert TTC files into TTF. Try: 'brew install fontforge'" ;;
        ubuntu*) errx "fontforge is required to convert TTC files into TTF. Try: 'sudo apt-get install -y fontforge'" ;;
      esac
    else
      echo -e "\n:: Using fontforge as CONVERT_TTF is set."
    fi
  fi

  pushd $temp_dir
  file=$(basename ${PPV_PATH})

  echo -e "\n:: Downloading ${file} from ${PPV_PATH}..."
  curl -L ${PPV_PATH} -o ${file} || \
    errx "\nDownload failed.\n"

  echo -e "Download Done!\n"

  echo -n ":: Extracting fonts from ${file}... "

  cabextract -t "$file" || \
    errx "Can't extract from ${file}. Corrupted download?"

  cabextract -F ppviewer.cab "$file" || \
    errx "Can't extract 'ppviewer.cab' from '${file}'. Corrupted download?"

  cabextract -L -F '*.tt?' ppviewer.cab || \
    errx "Can't extract '*.tt?' from 'ppviewer.cab'. Corrupted download?"

  echo -n ":: Installing... " >&2

  for fontfile in $(find . -maxdepth 1 -type f -name '*.tt*' -exec basename \{} \;); do
    process_font_${platform} $fontfile $MS_FONT_PATH || \
      errx "Process font $fontfile failed, exiting.".
  done

  # echo -n ":: Cleanup... "
  # cd - &> /dev/null
  rm -rf "$temp_dir" || \
    errx "Unable to remove temp directory ${temp_dir}."

  if [ "${platform}" == "ubuntu" ]; then
    echo ":: Cleaning the font cache... " >&2
    fc-cache -f "$MS_FONT_PATH" || \
      errx "Unable to clean font cache via 'fc-cache'. Exiting."
    echo "Done!" >&2
  fi

  echo -e "\nCongratulations! Installation successful!!\n" >&2
}

main $@

exit $?
