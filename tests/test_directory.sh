#!/bin/bash

testfile="$(pwd)/$1"
resultfile="$(pwd)/result.txt"

MS_FONT_PATH=${MS_FONT_PATH:-}

test_files_missing() {
  if [ "0" == "$(grep -v MISSING ${resultfile} | wc -l | tr -d ' ')" ]; then
    echo $*
    cat ${resultfile}
    exit 1
  fi
}

test_files_present() {
  if [ "0" == "$(grep -v PRESENT ${resultfile} | wc -l | tr -d ' ')" ]; then
    echo $*
    cat ${resultfile}
    exit 1
  fi
}

prepare_test_data() {
  echo -n "" > ${resultfile}
  cd "$MS_FONT_PATH"
  while IFS= read -r line
  do
    echo "$line"
    if [ -f "$line" ]; then
      echo "$MS_FONT_PATH/$line @ PRESENT" >> ${resultfile}
    else
      echo "$MS_FONT_PATH/$line @ MISSING" >> ${resultfile}
    fi
  done < "$testfile"
  cd $(dirname $resultfile)
}

test_files() {
  if [[ $2 == "accept_eula_by_parameter" ]]; then
    "$(./vista-fonts-installer.sh --accept-microsoft-eula)"
    prepare_test_data
    test_files_missing "At least one font file not being installed, see output:"

  elif [[ $2 == "accept_eula_manually" ]]; then
    "$(echo "yes" | ./vista-fonts-installer.sh)"
    prepare_test_data
    test_files_missing "At least one font file not being installed, see output:"

  elif [[ $2 == "reject_eula" ]]; then
    "$(echo "no" | ./vista-fonts-installer.sh)"
    exit_status = $?
    if [ "${exit_status}" == '0' ]; then
      exit 1
    fi
    prepare_test_data
    test_files_present "Files should not be installed when not accepting EULA."

  else
    "$(./vista-fonts-installer.sh)"
    prepare_test_data
    test_files_missing "At least one font file not being installed, see output:"
  fi
}

test_files $@
