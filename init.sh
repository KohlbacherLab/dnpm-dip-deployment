#!/bin/bash


# Create non-template copies of all template files, unless already present

for templateFile in backend-config/*.template.*; do

  file=${templateFile/.template}	

  if [ ! -f file ]; then 
    cp ${templateFile} ${file}
  fi
done	

for templateFile in certs/*.template.*; do

  file=${templateFile/.template}	

  if [ ! -f file ]; then 
    cp ${templateFile} ${file}
  fi
done	


if [ ! -f .env ]; then 
  cp .env.template .env
fi


