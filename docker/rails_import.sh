#!/bin/bash
bash docker/wait-for-it.sh -t 120 ${DB_HOST}:3306
timestamp="$(date +%s)"
curl -s -w "%{http_code}\\n" https://findtext.library.nd.edu/ndu_local/cgi/public/get_file.cgi?file=EJournal_Locator_Daily.xml -o import/ejl-full-e-collection-ALL.$timestamp.xml-marc
head -n1 import/ejl-full-e-collection-ALL.$timestamp.xml-marc
bundle exec rake journals:import