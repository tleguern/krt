#!/bin/sh

set -eu

i=1
while [ $i -lt 1000 ]; do
	echo -n "$((i * i)) "
	i=$(( i + 1))
done
