#!/usr/bin/bash

if [ "$#" -eq 0 ]; then
  echo "Comentario omitido"
  exit 1
fi

git add . --all
git commit -am "$1"
git push
