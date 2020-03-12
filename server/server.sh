#!/usr/bin/env bash

bundle check || bundle install

bundle exec puma -p $API_PORT -e production --log-requests