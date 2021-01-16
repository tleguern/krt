#!/bin/sh

. ../sqrt.sh

set -u

scale() {
	local n="$1"; shift
	local factor="$1"; shift

	echo $(( n * factor))
}

n=125348
nearest="$(fixed_nearest "$n" ../perfect_squares.txt)"

for params in "1000 354045" "10000 3540451" "100000 35404519"; do
	export FACTOR="$(echo "$params" | cut -d ' ' -f1)"
	expected="$(echo "$params" | cut -d ' ' -f2)"
	echo "Square root of $n with factor $FACTOR"
	fnearest="$(scale "$nearest" "$FACTOR")"
	fn="$(scale "$n" "$FACTOR")"
	res="$(heron "$fn" "$fnearest")"
	if [ "$res" -eq "$expected" ]; then
		echo heron OK
	else
		echo heron KO
	fi
	res="$(bakhshali "$fn" "$fnearest")"
	if [ "$res" -eq "$expected" ]; then
		echo bakhshali OK
	else
		echo bakhshali KO
	fi
	res="$(newton "$fn" "$fnearest")"
	if [ "$res" -eq "$expected" ]; then
		echo newton OK
	else
		echo newton KO
	fi
done
