#!/bin/sh

. ../vec.sh

res="$(vec3_add 1000 2000 3000 3000 2000 1000)"
if [ "$res" = "4000 4000 4000" ]; then
	echo vec3_add OK
else
	echo vec3_add KO
fi

res="$(vec3_sub 3000 2000 1000 1000 2000 3000)"
if [ "$res" = "2000 0 -2000" ]; then
	echo vec3_sub OK
else
	echo vec3_sub KO
fi

res="$(vec3_mul 3000 2000 1000 2000 2000 2000)"
if [ "$res" = "6000 4000 2000" ]; then
	echo vec3_mul OK
else
	echo vec3_mul KO
fi

res="$(vec3_mulf 3000 2000 1000 2000)"
if [ "$res" = "6000 4000 2000" ]; then
	echo vec3_mulf OK
else
	echo vec3_mulf KO
fi

res="$(vec3_div 6000 4000 2000 2000 2000 2000)"
if [ "$res" = "3000 2000 1000" ]; then
	echo vec3_div OK
else
	echo vec3_div KO
fi

res="$(vec3_divf 6000 4000 2000 2000)"
if [ "$res" = "3000 2000 1000" ]; then
	echo vec3_divf OK
else
	echo vec3_divf KO
fi

res="$(vec3_trunc 1000 2000 3000)"
if [ "$res" = "1 2 3" ]; then
	echo vec3_trunc OK
else
	echo vec3_trunc KO
fi

res="$(vec3_squared 1000 2000 3000)"
if [ "$res" = "1000 4000 9000" ]; then
	echo vec3_squared OK
else
	echo vec3_squared KO
fi

res="$(vec3_sum 1000 2000 3000)"
if [ "$res" = "6000" ]; then
	echo vec3_sum OK
else
	echo vec3_sum KO
fi

res="$(vec3_dot 1778 1000 -1000 1778 1000 -1000)"
if [ "$res" = "5160" ] || [ "$res" = "5161" ]; then
	echo vec3_dot OK
else
	echo vec3_dot KO
fi
