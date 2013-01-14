#!/usr/bin/env bash

# Load RVM-based ruby environment
echo "Loading ruby"
source /usr/local/rvm/environments/ruby-1.9.3-p194

WWW=/var/www/contribute
WORKING=/tmp/contribute-nightly

echo "Cloning git repository"
git clone /projects/contribute.git ${WORKING} > /dev/null
cd ${WORKING}

echo "Running nightly rake task"
rake nightly:send_email

echo "Publishing results"
rm -rf ${WWW}/coverage
rm -rf ${WWW}/doc

# Copy files from working directory to web directory
cp -r {${WORKING},${WWW}}/coverage
cp -r {${WORKING},${WWW}}/doc
cp -r {${WORKING},${WWW}}/public/specification.html

echo "Cleaning up"
rm -rf ${WORKING}

echo "Done"
