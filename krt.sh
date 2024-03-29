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
	trap reset ERR KILL
}

writeheader() {
	local width="$1"; shift
	local height="$1"; shift

	cat > header.ppm <<EOF
P3
$((width / 1000)) $((height / 1000))
255
EOF
}

progressreport() {
	local jobn="$(( $1 - 1 ))"; shift
	local lines="$1"; shift
	local max="$1"; shift

	if [ $lines -gt $max ]; then
		return
	fi
	lines="$((lines / 1000))"
	local progress=$((lines * 100 / (max / 1000) ))
	printf "$(tput cup $jobn 0)> job %d %d (%d%%)" "$jobn" "$lines" "$progress" >&2
}

drawcoloredline() {
	local y="$1"; shift
	local color="$1"; shift

	local x=
	for x in $($enum 0 $(( image_width - 1000 ))); do
		printf "%s\n" "$color"
	done
	y=$(( y - 1000 ))
}

drawredline() {
	local line="$1"; shift

	drawcoloredline "$line" "255 0 0"
}

drawgreenline() {
	local line="$1"; shift

	drawcoloredline "$line" "0 255 0"
}

drawblueline() {
	local line="$1"; shift

	drawcoloredline "$line" "0 0 255"
}

drawblackline() {
	local line="$1"; shift

	drawcoloredline "$line" "0 0 0"
}

drawwhiteline() {
	local line="$1"; shift

	drawcoloredline "$line" "255 255 255"
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

drawrectangle() {
	local start_at="$1"; shift
	local stop_at="$1"; shift
	local jobn="$1"; shift
	local func="${1:-drawline}"

	local y="$start_at"
	while [ "$y" -ge "$stop_at" ]; do
		progressreport "$jobn" $(( start_at - y )) $(( start_at - stop_at ))
		"$func" "$y" >> "part$jobn.ppm"
		y=$(( y - 1000 ))
	done
}

reset() {
	tput cnorm rc
}

init

# Image
aspect_ratio=$(( 16000 * 1000 / 9000 ))
image_width=$(( 400 * 1000 ))
image_height=$(( image_width * 1000 / aspect_ratio ))

# Clamp image_height
image_height=$(( image_height - image_height % 1000 ))

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

writeheader "$image_width" "$image_height"

# 19m30.71s real    10m19.75s user    43m24.53s system
tput sc clear civis
rm -f -- part1.ppm part2.ppm part3.ppm part4.ppm
drawrectangle "$(( image_height - 1000 ))" "$(( image_height / 4 * 3 ))" 1 &
drawrectangle "$(( (image_height - 1000) / 4 * 3 ))" "$(( image_height / 2 ))" 2 &
drawrectangle "$(( (image_height - 1000) / 2 ))" "$(( image_height / 4 ))" 3 &
drawrectangle "$(( (image_height - 1000) / 4 ))" 0 4 &

wait
reset

cat header.ppm part1.ppm part2.ppm part3.ppm part4.ppm > image.ppm
printf "\nFinish !\n"
