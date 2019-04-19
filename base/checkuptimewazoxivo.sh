#!/bin/bash
uptime=`uptime | sed -r '1 s/.*up *(.*),.*user.*/\1/g;q'`
echo "Uptime Wazo/Xivo : $uptime"
exit 0
