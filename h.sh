#!/bin/sh

while [ 1 -gt 0 ]; do 

sleep 1s; 

h=`date -j -f %Y-%m-%d:%H:%M:%S 2019-09-12:17:30:00 +%s`; 
n=`date +%s`; 

let "t=$h-$n"; 
echo "距离中秋放假时间还剩: ${t}s" ; 

done
