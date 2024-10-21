#!/bin/bash


# Create non-template copies of all template files, unless already present

for templateFile in backend-config/*.template.*; do

  file=${templateFile/.template}	

  if [ ! -f file ]; then cp ${templateFile} ${file}; fi
done	

for templateFile in certs/*.template.*; do

  file=${templateFile/.template}	

  if [ ! -f file ]; then cp ${templateFile} ${file}; fi
done	


if [ ! -d nginx/sites-enabled ]; then mkdir nginx/sites-enabled; fi

for templateFile in nginx/sites-available/*.template.*; do

   name=${templateFile##*/}

   file=nginx/sites-enabled/${name/.template}

  if [ ! -f file ]; then cp ${templateFile} ${file}; fi
done


if [ ! -f .env ]; then cp .env.template .env; fi

