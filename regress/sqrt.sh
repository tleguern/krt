#!/bin/sh

. ../sqrt.sh

scale() {
	local n="$1"; shift
	local factor="$1"; shift

	echo $(( n * factor))
}

n=125348
factor=1000
nearest="$(fixed_nearest "$n" ../perfect_squares.txt)"

echo "Square root of $n with factor $factor"
nearest="$(scale "$nearest" "$factor")"
fn="$(scale "$n" "$factor")"
res="$(heron "$fn" "$nearest")"
if [ "$res" -eq 354045 ]; then
	echo heron OK
else
	echo heron KO
fi
res="$(bakhshali "$fn" "$nearest")"
if [ "$res" -eq 354045 ]; then
	echo bakhshali OK
else
	echo bakhshali KO
fi
res="$(newton "$fn" "$nearest")"
if [ "$res" -eq 354045 ]; then
	echo newton OK
else
	echo newton KO
fi
