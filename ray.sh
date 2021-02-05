#
# A ray is a pair of vector: one for the origin, the other for the direction.
# It it therefore six parameters long so make sure the functions handling rays
# are idiot-proof.
#

# Example:
#   hit_sphere "0 0 -1" "0.5" "0 0 0 -1 -2 -3"
#   hit_sphere 0 0 -1 0.5 0 0 0 -1 -2 -3
# 38m de temps d'execution
hit_sphere() {
	if [ $# -eq 3 ]; then
		local center="$1"; shift
		local radius="$1"; shift
		local origin="$(echo "$1" | cut -d ' ' -f 1-3)"
		local direction="$(echo "$1" | cut -d ' ' -f 4-6)"
		shift
	else
		local center="$1 $2 $3"; shift 3
		local radius="$1"; shift
		local origin="$1 $2 $3"; shift 3
		local direction="$1 $2 $3"; shift 3
	fi

	local oc="$(vec3_sub $origin $center)"
	local a="$(vec3_dot $direction $direction)"
	local b="$(( 2000 * $(vec3_dot $oc $direction $origin) / 1000 ))"
	local c="$(( $(vec3_dot $oc $oc) - radius * radius / 1000))"
	local discriminant="$(( b * b - 4 * a * c ))"
	[ $discriminant -gt 0 ]
}

# Return the color of the background
ray_color() {
	if [ $# -eq 2 ]; then
		local origin="$1"; shift
		local direction="$1"; shift
	else
		local origin="$1 $2 $3"; shift 3
		local direction="$1 $2 $3"; shift 3
	fi

	if hit_sphere 0 0 -1000 500 $origin $direction; then
		echo "1000 0 0"
		return
	fi

	local unit_direction="$(vec3_unit_vector $direction)"
	local udy="$(echo "$unit_direction" | cut -d' ' -f2)"
	local t="$(( (udy + 1000) / 2 ))"
	local tmp1="$(vec3_mulf 1000 1000 1000 "$((1000 - t))" )"
	local tmp2="$(vec3_mulf 500 700 1000 "$t")"
	vec3_add $tmp1 $tmp2
}
