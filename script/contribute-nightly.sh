#!/usr/bin/env bash

# Load RVM-based ruby environment
echo "Loading ruby"
source /usr/local/rvm/environments/ruby-1.9.3-p194

WORKING=/tmp/contribute-nightly

echo "Cloning git repository"
git clone /projects/contribute.git ${WORKING} > /dev/null
cd ${WORKING}

echo "Running nightly rake task"
rake nightly:run

echo "Cleaning up"
rm -rf ${WORKING}

echo "Done"
