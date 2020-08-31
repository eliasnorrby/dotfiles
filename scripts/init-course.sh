#!/bin/bash

ORGANIZATION="en-learn"
REPO="${PWD##*/}"
LECTURE_COUNTER=lecture_counter
COURSE_MATERIALS=_course-materials

if [ ! -d ".git" ]; then
  echo "No .git folder found, initializing repo"
  git init
fi

if [ ! -f "$LECTURE_COUNTER" ] && [ "$1" != "0" ]; then
  echo "Setting up lecture counter"
  echo "0" >$LECTURE_COUNTER
  git add $LECTURE_COUNTER
fi

if [ ! -f .gitignore ] || ! grep "$COURSE_MATERIALS" .gitignore; then
  echo "Appending $COURSE_MATERIALS to .gitignore"
  echo "$COURSE_MATERIALS" >>.gitignore
  git add .gitignore
fi

echo "Committing changes"
git commit -m "Initialize course"

read -rp "Create new repository $ORGANIZATION/$REPO on GitHub? [y/n] " CHOICE

case $CHOICE in
  [yY] | [yY][eE][sS])
    echo "Creating remote repo"
    hub create "$ORGANIZATION/$REPO"
    echo "Pushing to remote"
    git push --set-upstream origin master
    ;;
  [nN] | [nN][oO])
    echo "Skipping creating repo"
    ;;
  *)
    echo "Invalid choice, skipping"
    ;;
esac

cat <<EOF

  Course initialization complete.

  Consider creating a README.md to describe the course.

EOF
