#!/bin/bash
#set -x

DOT_REPO="https://github.com/vrgio/.dot.git"
DOTDIR="${HOME}/.dot"

if [ -f "./config" ]; then
  . ./config
fi

usage() {
  cat << EOF
Usage: ./dot.sh
        Manage dotfiles following the bare git repo method 
EOF
}

#trap read debug

# make dir
cd "$HOME" || exit 1
if [ -d "$DOTDIR" ]; then
  mv "$DOTDIR" "${DOTDIR}-$(date +%Y%m%d%H%M)"
fi
mkdir "$DOTDIR"

bkupolddot() {
  mkdir "${DOTDIR}-$(date +%Y%m%d%H%M)/existing"
  mv "$files" "${DOTDIR}-$(date +%Y%m%d%H%M)/existing"
}

files=$(find "${*:-.}/" -maxdepth 1 -type f -name ".*" -print;)
if [ -z "$files" ]; then
  :
else
  printf "Dotfiles exist in %s\n" "$DOTDIR"
  printf "%s\n" "$files"
  printf "Backup these files?\n"
  read -r YESNO
  case "$YESNO" in
    ("yes"|"y"|"YES"|"Y")
      bkupolddot
      ;;
    (*)
      :
  esac 
fi

bkupolddot() {
  mkdir "${DOTDIR}-$(date +%Y%m%d%H%M)/existing"
  mv "$files" "${DOTDIR}-$(date +%Y%m%d%H%M)/existing"
}

dot() {
  /usr/bin/git --git-dir="$DOTDIR" --work-tree="$HOME" "$@"
}

# gitignore
echo ".dot" >> .gitignore

# clone remote
git clone --bare "$DOT_REPO" "$DOTDIR"

# checkout
dot checkout -f
# if we wanted backup we should have said so earlier

dot config --local status.showUntrackedFiles no

# reminder
echo "add alias to your aliases file:"
printf "alias dot='git --git-dir=%s --work-tree=%s'\n" "$DOTDIR" "$HOME"
