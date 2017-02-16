#!/bin/bash
# This will tell you the number of requests per 
# second. Throw this together with some options and 
# you will be cooking with crisco.
# scoday

cat httpd.log | awk ' $4>"[09/Jul/2015:13:59:59" && $4<"[09/Jul/2015:23:59:59" {gsub(/\[/,""); print $4} ' | sort | uniq -c
