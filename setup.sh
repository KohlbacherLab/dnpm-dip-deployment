#!/bin/bash



# Create non-template copies of all template files

for template in backend-config/*.template.*; do
  cp ${template} ${template/.template}
done	

for template in certs/*.template.*; do
  cp ${template} ${template/.template}
done	

cp .env.template .env


