#!/bin/bash
for i in $(cat carpetas); do
find ${i} -mindepth 1 -maxdepth 1 -type d -exec ls -ld {} + |awk 'NF {print $NF}'
done

