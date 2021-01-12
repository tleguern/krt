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

readonly KRTPROGNAME="$(basename $0)"
readonly KRTVERSION='v1.0'

usage() {
	echo "usage: $KRTPROGNAME [width height]" >&2
}

height=256
width=256

_enumjot() { jot - $1 $2 1; }
_enumseq() { seq $1 1 $(( $2 - 1 )); }
_enumslow() {
	i="$1"
	while [ "$i" -le "$2" ]; do
		printf "%d\n" "$i"
		i=$(( i + 1 ))
	done
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

loadslider() {
	local p="$1"; shift
	local max="$1"
	local lenght=50

	if [ $p -gt $max ]; then
		return
	fi
	local progress=$(( p * lenght / max ))
	local remain=$(( lenght - progress ))
	if [ $progress -eq 0 ]; then
		remain=$(( remain- 1 ))
	fi
	local position="$(printf %"$progress"s '=')"
	local empty="$(printf %"$remain"s ' ')"
	if [ "$remain" -eq 0 ]; then
		empty=''
	fi
	printf '|%s%s>\r' "$position" "$empty" >&2
}

krt() {
	cat <<EOF
P3
$width $height
255
EOF
	j=$(( height - 1 ))
	while [ "$j" -ge 0 ]; do
		loadslider "$(( height - j ))" "$height"
		for i in $($enum 0 $(( width - 1 ))); do
			r=$i
			g=$j
			b=63
			printf "%d %d %d\n" $r $g $b
		done
		j=$(( j - 1 ))
	done
	echo ""
}

if [ "${KRTPROGNAME%.sh}" = "krt" ] && [ "$*" != "as a library" ]; then
	while getopts ":" opt; do
		case $opt in
			:) echo "$KRTPROGNAME: option requires an argument -- $OPTARG" >&2;
			   usage; exit 1;;	# NOTREACHED
			\?) echo "$KBFPROGNAME: unknown option -- $OPTARG" >&2;
			   usage; exit 1;;	# NOTREACHED
			*) usage; exit 1;;	# NOTREACHED
		esac
	done
	shift $(( $OPTIND -1 ))

	if [ -n "$1" ] && [ -n "$2" ]; then
		width="$1"
		shift
		height="$1"
		shift
	fi

	if [ $# -ge 1 ]; then
		echo "$KRTPROGNAME: invalid trailing chars -- $@" >&2
		usage
		exit 1
	fi

	set -u

	init
	krt
fi
