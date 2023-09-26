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
  usage
  exit 1
fi

# line numbers must be positive ints
is_valid() {
  case $1 in
    ''|*[!0-9]*|*[!1-9]*) return 1 ;;
    *) return 0 ;;
  esac
}

# colourful output
out() {
  while IFS= read -r line; do
    echo "${line%%||*}"
    printf "${BLUE}Description${NC}: ${line#*||}\n"
    printf "${RED}----------------${NC}\n"
  done
}

case "$1" in
  -a|--add)
    printf "${BLUE}Description${NC}: \n"
    read -r descr
    echo "$2 | ${descr}" >> "$SNIPFILE"
    exit 0
    ;;
  -v|--view)
    if [ -s "$SNIPFILE" ]; then
      out < "$SNIPFILE"
      exit 0
    else
      echo "File $SNIPFILE empty"
      exit 0
    fi
    ;;
  -s|--search)
    if [ -z "$2" ]; then
      echo "Error: No search string"
      exit 1
    fi
    : > "$TMPFILE"
    grep -n -e "${2}" "$SNIPFILE" > "$TMPFILE"
    out < "$TMPFILE"
    rm "$TMPFILE"
    exit 0
    ;;
  -d|--del)
    if ! is_valid "${2}"; then
      echo "Invalid line number: $2"
      exit 1
    fi
    sed -i "${2}d" "$SNIPFILE"
    exit 0
    ;;
  -e|--empty)
    echo "Deleting all snippets, are you sure? [y]es/[n]o"
    read -r YESNO
    case "$YESNO" in
      ("yes"|"y"|"YES"|"Y")
        : > "$SNIPFILE"
        ;;
      (*)
        echo "Invalid option: $1"
        exit 1
    exit 0
  esac
    ;;
  *)
    usage
    exit 1
    ;;
esac
