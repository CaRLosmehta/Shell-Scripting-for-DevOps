#!/bin/bash

echo "System Resource Usage Report"

echo "----------------------------"

echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' )%"

echo "Memory Usage: $(free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3, $2 $3*100/$2 }')"

echo "Disk Usage: $(df -h / | awk 'NR==2{print $5}')"

crontab -e

*/5 * * * * /path/to/system_monitor.sh >> /var/log/sys_monitor.log

