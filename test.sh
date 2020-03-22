#!/bin/bash

set -ex

APP_NAME=pgbouncer-test-$(openssl rand -hex 4)
temp_dir=$(mktemp -d /tmp/$APP_NAME.XXXXXXXXXX)
exit_code=0

print_error () {
  printf "\e[31m$1\e[0m\n"
}

echo "logfile: $temp_dir/log.txt"
echo "running setup..."

heroku create --buildpack heroku/ruby -t pgbouncer-test $APP_NAME >> $temp_dir/log.txt 2>&1
heroku buildpacks:add https://github.com/heroku/heroku-buildpack-pgbouncer.git -a $APP_NAME >> $temp_dir/log.txt 2>&1

heroku addons:create heroku-postgresql:hobby-dev -a $APP_NAME >> $temp_dir/log.txt 2>&1
heroku builds:create --source-url=https://github.com/beanieboi/heroku-buildpack-pgbouncer-test/archive/master.tar.gz -a $APP_NAME >> $temp_dir/log.txt 2>&1
heroku ps:wait -a $APP_NAME >> $temp_dir/log.txt 2>&1

echo "running tests..."
dbhost=$(curl -s https://$APP_NAME.herokuapp.com/dbsettings | jq '.host')

# make sure the buildpack overwrites the DATABASE_URL when using the wrapper
if [ "$dbhost" != '"127.0.0.1"' ]; then
  print_error "wrong DATABASE_URL"
  exit_code=1
fi

dbcontent=$(curl -s https://$APP_NAME.herokuapp.com/items)
number_of_items=$(echo $dbcontent | jq '. | length')

if [ "$number_of_items" -ne "3" ]; then
  print_error "wrong number of items"
  exit_code=1
fi

echo "running cleanup..."
heroku destroy -c $APP_NAME -a $APP_NAME >> $temp_dir/log.txt 2>&1

exit $exit_code
