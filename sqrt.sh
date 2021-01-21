fixed_nearest() {
	local i="$1"; shift
	if [ $# -eq 1 ]; then
		local input="$1"; shift
	else
		local input=./perfect_squares.txt
	fi
	local x=1

	set $(< "$input")
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
	local S="$1"; shift
	local x="$1"; shift
	if [ $# -ge 1 ]; then
		local maxsteps="$1"
	else
		local maxsteps=5
	fi
	local factor="${FACTOR:-1000}"
	local steps=1

	while [ "$steps" -lt "$maxsteps" ]; do
		local nextx=$(( x - (x * x / factor - S) * factor / (2 * x) ))
		if [ "$x" = "$nextx" ]; then
			break
		fi
		x="$nextx"
		#echo "$steps / $maxsteps" >&2
		steps=$(( steps + 1 ))
	done
	printf "%d\n" "$x"
}

heron() {
	local S="$1"; shift
	local x="$1"; shift
	if [ $# -ge 1 ]; then
		local maxsteps="$1"
	else
		local maxsteps=5
	fi
	local factor="${FACTOR:-1000}"
	local steps=1

	while [ "$steps" -lt "$maxsteps" ]; do
		local nextx=$(( (x + S * factor / x) / 2 ))
		if [ "$x" = "$nextx" ]; then
			break
		fi
		x="$nextx"
		#echo "$steps / $maxsteps" >&2
		steps=$(( steps + 1 ))
	done
	printf "%d\n" "$x"
}

bakhshali() {
	local S="$1"; shift
	local x="$1"; shift
	local factor="${FACTOR:-1000}"

	for steps in 1 2; do
		local a=$(( (S - x * x / factor) * factor / (2 * x) ))
		local b=$(( x + a ))
		local nextx=$(( b - (a * a / factor) * factor / (2 * b) ))
		x="$nextx"
	done
	printf "%d\n" "$x"
}

cheating_with_bc() {
	local S="$1"; shift
	local factor="${FACTOR:-1000}"
	local scale="$(printf "%d" $factor | tr -d '[1-9]' | wc -c)"

	local res="$(bc -l -e "scale=$scale; sqrt($S/$factor)*$factor" -e quit)"
	echo "$res" | cut -d '.' -f 1
}

# Example from wikipedia: sqrt(125348)
# nearest=$(fixed_nearest 125348)
# heron $((125348 * 1000)) $(( nearest * 1000 ))
# bakhshali $((125348 * 1000)) $(( nearest * 1000 ))
# newton $((125348 * 1000)) $(( nearest * 1000 ))

# Example: sqrt(5.160)
# nearest=$(fixed_nearest $(( 5160 / 1000 )))
# newton 5160 $(( nearest * 1000 ))
# heron 5160 $(( nearest * 1000 ))
# bakhshali 5160 $(( nearest * 1000 ))
