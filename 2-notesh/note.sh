#!/bin/sh
#set -x

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
  my_pager="$(command -v less || command -v more || command -v most || command -v pg || command -v nano --view)"
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
Usage: ./note.sh [options] <filename>

options:    -- add <filename> (adds new note. If filename is empty, generate
                    a filename)
            -- view filename (view contents of a note)
            -- edit filename (edit note)
            -- del filename (move note to NOTEDIR/.trash)
            -- emptytrash (empty NOTEDIR/.trash)
            -- backup (create a backup of all notes)
EOF
}

# count files in notedir
count_f() {
  n=0
  for f in "$NOTEDIR"/*; do
    if test -e "$f" || test -L "$f"; then n=$((n+1)); fi
  done
}

if [ $# -eq 0 ]; then
  count_f
  printf "NOTEDIR is %s. There are %s notes:\n" "$NOTEDIR" "$n"
  for f in "$NOTEDIR"/*; do
    if [ "$n" -ne 0 ]; then
      echo "- $(basename "$f")"
    fi
  done
  exit 0
fi

case "$1" in
  add)
    if [ $# -eq 2 ]; then
      note_name="${2}.${FILETYPE}"
    else
      note_name="${now_date}.${FILETYPE}"
    fi
    touch "${NOTEDIR}/${note_name}"
    "$my_editor" "${NOTEDIR}/${note_name}"
    ;;
  view)
    "$my_pager" "${NOTEDIR}/${2}"
    ;;
  edit)
    "$my_editor" "${NOTEDIR}/${2}"
    ;;
  del)
    if [ -f "${NOTEDIR}/${2}" ]; then
      mv "${NOTEDIR}/${2}" "${TRASH}/"
    elif [ -d "${NOTEDIR}/${2}" ]; then
      echo "$2 is a directory"
    else
      echo "$2 does not exist"
    fi
    ;;
  emptytrash)
    rm -r "${TRASH:?}/"
    ;;
  backup)
    tar -zcvf "/tmp/${now_date}-notes_bk.tar.gz" "${NOTEDIR}"
    printf "File %s created at /tmp\n" "${now_date}-notes_bk.tar.gz"
    ;;
  *)
    usage
    ;;
esac
