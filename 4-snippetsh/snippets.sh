#!/bin/sh
#set -x

SNIPFILE="${HOME}/.snippets"
TMPFILE="/tmp/.snippets.sh.tmp"

: >> "$SNIPFILE"

RED="\033[0;31m"
BLUE="\033[0;36m"
NC="\033[0m" # no colour

usage() {
  cat << EOF
Usage: ./snippets.sh [OPTIONS] [LINE NUMBER] [PATTERN]

options:    -a|--add (adds new snippet)
            -v|--view (view all existing snippets)
            -s|--search [PATTERN] (search snippet with [PATTERN])
            -d|--del [LINE NUMBER] (delete a snippet)
            -e|--empty (delete all contents)
EOF
}

#trap read debug

if [ $# -eq 0 ]; then
  if [ -s "$SNIPFILE" ]; then
    nl < "${SNIPFILE%%|*}"
  else
    echo "File $SNIPFILE empty"
  fi
  exit 0
fi

# colourful output
out() {
  while IFS= read -r line; do
    echo "${line%%|*}"
    printf "${BLUE}Description${NC}: ${line#*|}\n"
    printf "${RED}----------------${NC}\n"
  done
}

case "$1" in
  -a|--add)
    printf "${BLUE}Description${NC}: \n"
    read -r descr
    echo "$2 | ${descr}" >> "$SNIPFILE"
    ;;
  -v|--view)
    out < "$SNIPFILE"
    ;;
  -s|--search)
    : > "$TMPFILE"
    grep -n -e "${2}" "$SNIPFILE" > "$TMPFILE"
    out < "$TMPFILE"
    rm $TMPFILE
    ;;
  -d|--del)
    sed -i "${2}d" "$SNIPFILE"
    ;;
  -e|--empty)
    echo "Deleting all snippets, are you sure? [y]es/[n]o"
    read -r YESNO
    case "$YESNO" in
      ("yes"|"y"|"YES"|"Y")
        : > "$SNIPFILE"
        ;;
      (*)
      exit 0
  esac
    ;;
  *)
    usage
    ;;
esac
