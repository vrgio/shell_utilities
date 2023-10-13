#!/bin/sh
set -e

NOTEDIR="${HOME}/.notes"
TRASHDIR=".trash"
FILETYPE="md"

# find editor
if [ -n "${EDITOR+x}" ]; then
  my_editor="$EDITOR";
else
  my_editor="$(command -v vim || command -v vi || command -v nvi || command -v nanoi || command -v pico || command -v ed)"
fi

# find pager
if [ -n "${PAGER+x}" ]; then
  my_pager="$PAGER";
else
  my_pager="$(command -v less || command -v more || command -v most || command -v bat || command -v pg || command -v nano --view)"
fi

# find date
if command -v gdate 2>/dev/null; then
  now_date=$(gdate +%Y%m%d-%Hh%M)
else
  now_date=$(date +%Y%m%d-%Hh%M)
fi

# use values from config file if exists
if [ -f "./config" ]; then
  . ./config
fi

# create dirs
mkdir -p "${NOTEDIR}/${TRASHDIR}"
TRASH="${NOTEDIR}/${TRASHDIR}"

usage() {
  cat << EOF
Usage: ./note.sh [options] <filename|file number>

options:    -a|--add [filename] (adds new note. If filename is empty, generate
                    a filename)
            -v|--view <filename|file number> (view contents of a note)
            -e|--edit <filename|file number> (edit note)
            -d|--del <filename|file number> (move note to $NOTEDIR/.trash)
            -c|--cleartrash (empty $NOTEDIR/.trash)
            -b|--backup (create a backup of all notes)
            -h|--help (print this help message)
EOF
}

#set -x
#trap read debug

# count files in notedir
count_f() {
  n=0
  for f in "$NOTEDIR"/*; do
    if test -e "$f" || test -L "$f"; then n=$((n+1)); fi
  done
}

count_f
n_files="$n"

# enumerated file list
enum_f() {
  printf "NOTEDIR is %s. There are %s notes\n" "$NOTEDIR" "$n_files"
  i=1
  for f in "$NOTEDIR"/*; do
    if test -e "$f" || test -L "$f"; then
      echo "${i} - $(basename "$f")"
      i=$((i+1))
    fi
  done
}

if [ $# -eq 0 ]; then
  enum_f
fi

if [ "$2" -eq "$2" ]  2>/dev/null; then
  myfile=$(eval "ls -1 \"\$NOTEDIR\" | grep -E '^\S' | sed -n ${2}p")
else
  myfile="$2"
fi

show_or_edit() {
  note_path="${NOTEDIR}/${myfile}"
  if [ -f "$note_path" ]; then
    if [ "$edit_mode" -eq 1 ]; then
      "$my_editor" "$note_path"
    else
      "$my_pager" "$note_path"
    fi
  else
    echo "File $myfile does not exist."
  fi
}

case "$1" in
  -a|--add)
    if [ $# -eq 2 ]; then
      note_name="${2}.${FILETYPE}"
    else
      note_name="${now_date}.${FILETYPE}"
    fi
    touch "${NOTEDIR}/${note_name}"
    "$my_editor" "${NOTEDIR}/${note_name}"
    ;;
  -v|--view)
    edit_mode=0
    show_or_edit
    ;;
  -e|--edit)
    edit_mode=1
    show_or_edit
    ;;
  -d|--del)
    if [ -f "${NOTEDIR}/${myfile}" ]; then
      mv "${NOTEDIR}/${myfile}" "${TRASH}/"
    elif [ -d "${NOTEDIR}/${myfile}" ]; then
      echo "$2 is a directory"
    else
      echo "$2 does not exist"
    fi
    ;;
  -c|--cleartrash)
    rm -r "${TRASH:?}/"
    ;;
  -b|--backup)
    tar -zcvf "/tmp/${now_date}-notes_bk.tar.gz" "${NOTEDIR}"
    printf "File %s created at /tmp\n" "${now_date}-notes_bk.tar.gz"
    ;;
  -h|--help)
    usage
    ;;
esac
