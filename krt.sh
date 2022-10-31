#!/bin/ksh
#
# Copyright (c) 2020 Tristan Le Guern <tleguern@bouledef.eu>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

set -e
set -f

readonly PROGNAME="$(basename $0)"
readonly VERSION='v1.0'

usage() {
	echo "usage: $PROGNAME [-s sqrt] [-n nearest]" >&2
}

sflag=newton
nflag=fixed

while getopts ":s:n:" opt; do
	case $opt in
		s) sflag="$OPTARG";;
		n) nflag="$OPTARG";;
		:) echo "$PROGNAME: option requires an argument -- $OPTARG" >&2;
		   usage; exit 1;;	# NOTREACHED
		\?) echo "$KBFPROGNAME: unknown option -- $OPTARG" >&2;
		   usage; exit 1;;	# NOTREACHED
		*) usage; exit 1;;	# NOTREACHED
	esac
done
shift $(( $OPTIND -1 ))

if [ $# -ge 1 ]; then
	echo "$PROGNAME: invalid trailing chars -- $@" >&2
	usage
	exit 1
fi

case "$sflag" in
newton|heron|bakhshali) :;;
*) echo "$PROGNAME: invalid square root function name" >&2;;
esac

case "$nflag" in
fixed|dynamic) :;;
*) echo "$PROGNAME: invalid nearest square root finding method" >&2;;
esac

if [ "$nflag" = fixed ] && ! [ -f perfect_squares.txt ]; then
	echo "$PROGNAME: please generate perfect_squares.txt"  >&2
fi

set -u

# Regular enum but adapted to fixed point representation
_enumjot() { jot - $1 $2 1000; }
_enumseq() { seq $1 1000 $2; }
_enumslow() {
	i="$1"
	while [ "$i" -le "$2" ]; do
		printf "%d\n" "$i"
		i=$(( i + 1000 ))
	done
}

. ./sqrt.sh
. ./vec.sh
. ./ray.sh

_sqrt() {
	nearest="$("$nflag"_nearest "$(( $1 / 1000 ))")"
	s=$("$sflag" "$1" "$(( nearest * 1000 ))")
	echo "$s"
}

init() {
	if command -v jot > /dev/null 2>&1; then
		enum=_enumjot
	elif command -v seq > /dev/null 2>&1; then
		enum=_enumseq
	else
		enum=_enumslow
	fi
}

progressreport() {
	local current="$1"; shift
	local max="$1"; shift

	if [ $current -gt $max ]; then
		return
	fi
	current="$((current / 1000))"
	max="$((max / 1000))"
	local progress=$(( current * 100 / max ))
	printf "> Generating image line %d (%d%%)\r" "$current" "$progress" >&2
}

drawline() {
	local y="$1"; shift
	local x=

	local v=$(( y * 1000 / (image_height - 1000) ))
	for x in $($enum 0 $(( image_width - 1000 ))); do
		local u=$(( x * 1000 / (image_width - 1000) ))
		local tmp1="$(vec3_mulf $horizontal $u)"
		local tmp2="$(vec3_mulf $vertical $v)"
		local tmp3="$(vec3_add $lower_left_corner $tmp1)"
		local tmp4="$(vec3_sub $tmp2 $origin)"
		local direction="$(vec3_add $tmp3 $tmp4)"
		local color="$(ray_color "$origin" "$direction")"
		# Readjust the value to the RGB scope
		color="$(vec3_mulf $color 255990)"
		color="$(vec3_trunc $color)"
		printf "%d %d %d\n" $color
	done
}

init

# Image
aspect_ratio=$(( 16000 * 1000 / 9000 ))
image_width=$(( 400 * 1000 ))
image_height=$(( image_width * 1000 / aspect_ratio ))

# Camera
viewport_height=2000
viewport_width=$(( aspect_ratio * viewport_height / 1000 ))
focal_length=1000

origin="0 0 0"
horizontal="$viewport_width 0 0"
vertical="0 $viewport_height 0"
tmp1=$(vec3_divf $horizontal 2000)
tmp2=$(vec3_divf $vertical 2000)
tmp3=$(vec3_sub $origin $tmp1)
tmp4=$(vec3_sub $tmp3 $tmp2)
lower_left_corner=$(vec3_sub $tmp4 0 0 $focal_length)

cat > image.ppm <<EOF
P3
$((image_width / 1000)) $((image_height / 1000))
255
EOF

y=$(( image_height - 1000 ))
while [ "$y" -ge 0 ]; do
	progressreport "$(( (image_height - y) ))" "$image_height"
	drawline "$y" >> image.ppm
	y=$(( y - 1000 ))
done

printf "\nFinish !\n"
