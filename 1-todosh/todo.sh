#!/bin/sh
#set -x

TODO="${HOME}/.todo"

: >> "$TODO"

usage() {
  cat << EOF
Usage: ./todo.sh [options] <text|line_number> <u|d>

options:    -- add "<text>" (adds new item in list)
            -- del <line_number> (removes item from list)
            -- flag <line_number> <u|d> (flags item in specific line number
                    with "URGENT" or "DONE")
            -- urgent (display items flagged as "URGENT")
            -- done (display items flagged as "DONE")
            -- cleardone (remove all items flagged as "DONE")
            -- empty (delete todolist contents)
EOF
}

#trap read debug

if [ $# -eq 0 ]; then
  nl < "$TODO"
  exit 0
fi

case "$1" in
  add)
    echo "$2" >> "$TODO"
    ;;
  del)
    sed -i "${2}d" "$TODO"
    ;;
  flag)
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
  urgent)
    grep URGENT "$TODO"
    ;;
  done)
    grep DONE "$TODO"
    ;;
  cleardone)
    sed -i "/DONE$/d" "$TODO"
    ;;
  empty)
    : > "$TODO"
    ;;
  *)
    usage
    ;;
esac
