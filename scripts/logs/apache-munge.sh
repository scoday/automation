#!/bin/bash
#
# Extract http response codes from each line in an NCSA log.
# Count each response code, again this sounds like every code not just 301s
# Count 301s / second outputting the total number of requests for each second? 
# Just define all codes for time and reuse #
# Turns out this inefficient log parser is very good at parsing most any kind of log. Go figure
# sometimes the lines are blured between Operational Excellence and hacking scripts. This worked well
# with some mods against various /var/log/*.logs
CODE="200"
CODE2="202"
CODE3="301"
CODE4="302"
CODE5="400"
CODE6="401"
CODE7="403"
CODE8="404"
CODE9="405"
CODE10="500"
CODE11="501"
# Define file names #
LOG="httpd.log"
ACODES="allcodes.log"
TOTCODES="totals.log"
RAWLOG="raw301.log"
TIMESTART="[09/Jul/2015:13:59:59"
TIMESTOP="[09/Jul/2015:23:59:59"
PERSEC="301sPerSecond.log"

raw_log() {
   grep " 301 " $LOG > $RAWLOG
}

extract_codes() {
   cat $LOG | grep -oP '(?<=HTTP\/1\.1"\s)\d+' > $ACODES
}

count_codes() {
  cat $ACODES | grep $CODE   | wc -l > $TOTCODES
  cat $ACODES | grep $CODE2  | wc -l >> $TOTCODES
  cat $ACODES | grep $CODE3  | wc -l >> $TOTCODES
  cat $ACODES | grep $CODE4  | wc -l >> $TOTCODES
  cat $ACODES | grep $CODE5  | wc -l >> $TOTCODES
  cat $ACODES | grep $CODE6  | wc -l >> $TOTCODES
  cat $ACODES | grep $CODE7  | wc -l >> $TOTCODES
  cat $ACODES | grep $CODE8  | wc -l >> $TOTCODES
  cat $ACODES | grep $CODE9  | wc -l >> $TOTCODES
  cat $ACODES | grep $CODE10 | wc -l >> $TOTCODES
  cat $ACODES | grep $CODE11 | wc -l >> $TOTCODES
}

add_headers() {
  sed -i '1 i\Total 200s:' $TOTCODES
  sed -i '3 i\Total 202s:' $TOTCODES
  sed -i '5 i\Total 301s:' $TOTCODES
  sed -i '7 i\Total 302s:' $TOTCODES
  sed -i '9 i\Total 400s:' $TOTCODES
  sed -i '11 i\Total 401s:' $TOTCODES
  sed -i '13 i\Total 403s:' $TOTCODES
  sed -i '15 i\Total 404s:' $TOTCODES
  sed -i '17 i\Total 405s:' $TOTCODES
  sed -i '19 i\Total 500s:' $TOTCODES
  sed -i '21 i\Total 501s:' $TOTCODES
}

sec3_count() {
  cat raw301.log | awk ' $4>"[09/Jul/2015:13:59:59" && $4<"[09/Jul/2015:23:59:59" {gsub(/\[/,""); print $4} ' | sort | uniq -c > $PERSEC
  rm $RAWLOG
}

# Comment out to run whaterver #
raw_log
extract_codes
count_codes
add_headers
sec3_count
