#!/bin/sh
#set -x

TODO="${HOME}/.todo"

: >> "$TODO"

usage() {
  cat << EOF
Usage: ./todo.sh [options] <text|line_number> <u|d>

options:    -a|--add "<text>" (adds new item in list)
            -r|--del <line_number> (removes item from list)
            -f|--flag <line_number> <u|d> (flags item in specific line number
                    with "URGENT" or "DONE")
            -u|--urgent (display items flagged as "URGENT")
            -d|--done (display items flagged as "DONE")
            -c|--cleardone (remove all items flagged as "DONE")
            -e|--empty (delete todolist contents)
EOF
}

#trap read debug

if [ $# -eq 0 ]; then
  nl < "$TODO"
  exit 0
fi

case "$1" in
  -a|--add)
    echo "$2" >> "$TODO"
    ;;
  -r|--del)
    sed -i "${2}d" "$TODO"
    ;;
  -f|--flag)
    if [ "$#" -ne 3 ]; then
      usage
      exit 1
    fi
    if [ "$3" = "u" ]; then
      sed -i "${2}s/$/ URGENT/" "$TODO"
    elif [ "$3" = "d" ]; then
      sed -i "${2}s/$/ DONE/" "$TODO"
    else
      usage
    fi
    ;;
  -u|--urgent)
    grep URGENT "$TODO"
    ;;
  -d|--done)
    grep DONE "$TODO"
    ;;
  -c|--cleardone)
    sed -i "/DONE$/d" "$TODO"
    ;;
  -e|--empty)
    : > "$TODO"
    ;;
  *)
    usage
    ;;
esac
