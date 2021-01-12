fixed_nearest() {
	local x=1
	local i="$1"

	local input=./perfect_squares.txt
	set $(< $input)
	while ! [ "$i" -le "$2" ]; do
		x=$(( x + 1 ))
		shift
	done
	echo "$x"
}

dynamic_nearest() {
	local x=0
	local i="$1"

	while [ $i -gt 0 ]; do
		local j=1
		while [ "$j" -lt "$i" ]; do
			if [ $((j * j)) -eq "$i" ]; then
				x=$j
				break 2
			fi
			j=$(( j + 1 ))
		done
		i=$(( i - 1 ))
	done
	echo $x
}

newton() {
	local S="$(( $1 * 1000 ))"; shift
	local x=$(( $1 * 1000 )); shift
	if [ $# -ge 1 ]; then
		local maxsteps="$1"
	else
		local maxsteps=5
	fi
	local steps=1

	while [ "$steps" -lt "$maxsteps" ]; do
		local nextx=$(( x - (x * x / 1000 - S) * 1000 / (2 * x) ))
		steps=$(( steps + 1 ))
		if [ "$x" = "$nextx" ]; then
			break
		fi
		x="$nextx"
	done
	printf "%d\n" "$x"
}

heron() {
	local S="$(( $1 * 1000 ))"; shift
	local x=$(( $1 * 1000 )); shift
	if [ $# -ge 1 ]; then
		local maxsteps="$1"
	else
		local maxsteps=5
	fi
	local steps=1

	while [ "$steps" -lt "$maxsteps" ]; do
		local nextx=$(( (x + S * 1000 / x) / 2 ))
		steps=$(( steps + 1 ))
		if [ "$x" = "$nextx" ]; then
			break
		fi
		x="$nextx"
	done
	printf "%d\n" "$x"
}

bakhshali() {
	local S="$(( $1 * 1000 ))"; shift
	local x=$(( $1 * 1000 )); shift

	for steps in 1 2; do
		local a=$(( (S - x * x / 1000) * 1000 / (2 * x) ))
		local b=$(( x + a ))
		local nextx=$(( b - (a * a / 1000) * 1000 / (2 * b) ))
		x="$nextx"
	done
	printf "%d\n" "$x"
}

# Example from wikipedia:
# nearest=$(fixed_nearest 125348)
# heron 125348 $nearest
# bakhshali 125348 $nearest
# newton 125348 $nearest
