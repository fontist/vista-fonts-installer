#!/bin/bash
set -e # Exit with nonzero exit code if anything fails

readonly __progname=macos-vista-fonts-installer
readonly PPV_PATH_1=https://web.archive.org/web/20171225132744/http://download.microsoft.com/download/E/6/7/E675FFFC-2A6D-4AB0-B3EB-27C9F8C8F696/PowerPointViewer.exe
PPV_PATH_2=https://www.dropbox.com/s/dl/6lclhxpydwgkjzh/PowerPointViewer.exe?dl=1
PPV_PATH=${PPV_PATH:-$PPV_PATH_1}
PPV_SHA=249473568eba7a1e4f95498acba594e0f42e6581add4dead70c1dfb908a09423

CONVERT_TTF=${CONVERT_TTF:-}

ACCEPT_EULA=${ACCEPT_EULA:-}
if [ $1 == "--accept-microsoft-eula" ]; then
  ACCEPT_EULA="true"
  shift
fi

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

process_font_raw() {
  fontfile="$1"
  dest_dir="$2"
  destname="$fontfile"

  if [ "${CONVERT_TTF}" == "true" ]; then

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
    errx "Cant move \"$destname\" into \"$dest_dir\""

  echo "Processing \"$fontfile\" into \"$dest_dir/$destname\" complete." >&2
}

process_font_rename() {
  fontfile="$1"
  destname="$fontfile"

  if [ "$fontfile" == "cambria.ttc" ]; then
    destname="Cambria.ttc"
  elif [ "$fontfile" == "meiryo.ttc" ]; then
    destname="Meiryo.ttc"
  elif [ "$fontfile" == "meiryob.ttc" ]; then
    destname="Meiryo Bold.ttc"
  elif [ "$fontfile" == "cambria.ttf" ]; then
    destname="Cambria.ttf"
  elif [ "$fontfile" == "cambriamath.ttf" ]; then
    destname="Cambria Math.ttf"
  elif [ "$fontfile" == "meiryo.ttf" ]; then
    destname="Meiryo.ttf"
  elif [ "$fontfile" == "meiryoi.ttf" ]; then
    destname="Meiryo Italic.ttf"
  elif [ "$fontfile" == "meiryoui.ttf" ]; then
    destname="Meiryo UI.ttf"
  elif [ "$fontfile" == "meiryouii.ttf" ]; then
    destname="Meiryo UI Italic.ttf"
  elif [ "$fontfile" == "meiryob.ttf" ]; then
    destname="Meiryo Bold.ttf"
  elif [ "$fontfile" == "meiryoz.ttf" ]; then
    destname="Meiryo Bold Italic.ttf"
  elif [ "$fontfile" == "meiryouib.ttf" ]; then
    destname="Meiryo UI Bold.ttf"
  elif [ "$fontfile" == "meiryouiz.ttf" ]; then
    destname="Meiryo UI Bold Italic.ttf"
  elif [ "$fontfile" == "calibri.ttf" ]; then
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
  else
    # This file is not supported
    echo "Renaming \"$fontfile\" skipped as it is not supported." >&2
    return
  fi

  mv -f "$fontfile" "$destname" || \
    errx "Can't rename \"$fontfile\" into \"$destname\"; PWD($(pwd))"

  echo "Renaming \"$fontfile\" into \"$destname\" complete." >&2
}


main() {
  platform=$(get_os)

  if [ "${platform}" == "macos" ]; then
    echo "Detected platform: macOS" >&2
  elif [ "${platform}" == "linux" ]; then
    for plat in ubuntu debian linuxmint; do
      if [ "$(get_linux_dist)" == "${plat}" ]; then
        echo "Detected platform: ${plat}" >&2
        platform="${plat}"
        break
      fi
    done

    if [ "${platform}" == "linux" ]; then
      errx "Linux distribution $(get_linux_dist) is not supported. Please contribute a fix!"
    fi

  else
    errx "platform ${platform} is not supported. Please contribute a fix!"
  fi

  RENAME_FONTS=${RENAME_FONTS:-}
  if [ "${RENAME_FONTS}" == "" ] && [ "${platform}" == "macos" ]; then
    RENAME_FONTS="true"
  fi

  MS_FONT_PATH=${1:-$MS_FONT_PATH}
  if [ "${MS_FONT_PATH}" == "" ]; then
    case ${platform} in
      macos*) MS_FONT_PATH="$HOME/Library/Fonts/Microsoft" ;;
      ubuntu*) MS_FONT_PATH="/usr/share/fonts/truetype/vista" ;;
      debian*) MS_FONT_PATH="/usr/share/fonts/truetype/vista" ;;
      linuxmint*) MS_FONT_PATH="/usr/share/fonts/truetype/vista" ;;
      *) exit 1 ;;
    esac
  fi

  [[ -d ${MS_FONT_PATH} ]] || \
    mkdir -p "${MS_FONT_PATH}" || \
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

  if [ "${CONVERT_TTF}" == "true" ]; then
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

  for url in ${PPV_PATH} ${PPV_PATH_2}; do
    echo -e "\n:: Downloading ${file} from ${url}..."
    curl --connect-timeout 5 -L ${url} -o ${file}

    if [ ! -f ${file} ]; then
      echo "\nDownload failed from ${url}, trying next." >&2
      continue
    fi

    # Check checksum of file
    echo "249473568eba7a1e4f95498acba594e0f42e6581add4dead70c1dfb908a09423  ${file}" > ${file}.sha256
    if [ -n "$(shasum -a 256 -c ${file}.sha256 | grep FAILED)" ]; then
      echo -e "\nDownload from ${url} had bad checksum, trying next.\n" >&2
      continue
    else
      echo -e "\nDownload from ${url} succeeded!\n" >&2
      break
    fi
  done

  [ ! -f ${file} ] && \
    errx "\nDownload failed from all URLs.\n"

  echo -n ":: Extracting fonts from ${file}... " >&2

  cabextract -t "$file" || \
    errx "Can't extract from ${file}. Corrupted download?"

  cabextract -F ppviewer.cab "$file" || \
    errx "Can't extract 'ppviewer.cab' from '${file}'. Corrupted download?"

  cabextract -L -F '*.tt?' ppviewer.cab || \
    errx "Can't extract '*.tt?' from 'ppviewer.cab'. Corrupted download?"

  if [ "${ACCEPT_EULA}" != "true" ]; then
    cabextract -L -F 'EULA' "$file" || \
      errx "Can't extract EULA from '$file'. Corrupted download?"

    cat "eula"

    echo -n "Do you accept EULA? (yes/no): "
    read input

    if [ "${input}" != "yes" ]; then
      errx "Unable to install some fonts. EULA not accepted"
    fi
  fi

  echo -n ":: Accepted the End User License Agreement (EULA)... " >&2

  echo -n ":: Installing... " >&2

  for fontfile in $(find . -maxdepth 1 -type f -name '*.tt*' -exec basename \{} \;); do
    process_font_raw $fontfile $MS_FONT_PATH || \
      errx "Process font $fontfile failed, exiting.".
  done

  if [ "${RENAME_FONTS}" == "true" ]; then
    pushd $MS_FONT_PATH
    ls -al
    for fontfile in $(find . -maxdepth 1 -type f -name '*.tt*' -exec basename \{} \;); do
      process_font_rename $fontfile $MS_FONT_PATH || \
        errx "Rename font $fontfile failed, exiting.".
    done
    popd
  fi

  # echo -n ":: Cleanup... "
  # cd - &> /dev/null
  rm -rf "$temp_dir" || \
    errx "Unable to remove temp directory ${temp_dir}."

  if [ "${platform}" == "ubuntu" ] && [ ! $(which fc-cache) ]; then
    echo ":: Cleaning the font cache... " >&2
    fc-cache -f "$MS_FONT_PATH" || \
      errx "Unable to clean font cache via 'fc-cache'. Exiting."
    echo "Done!" >&2
  fi

  echo -e "\nCongratulations! Installation successful!!\n" >&2
}

main $@

exit $?
