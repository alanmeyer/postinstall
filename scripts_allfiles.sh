#!/bin/sh
MY_LOG_FILE=~root/scripts/allfiles.txt
ls -lR / > $MY_LOG_FILE 2>&1
