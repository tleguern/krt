#
# A ray is a pair of vector: one for the origin, the other for the direction
#

# Return the color of the background
ray_color() {
	local origin="$1"; shift
	local direction="$1"; shift

	local unit_direction=$(vec3_unit_vector $direction)
	local udy="$(echo "$unit_direction" | cut -d' ' -f2)"
	local t=$(( (udy + 1000) / 2 ))
	local tmp1="$(vec3_mulf 1000 1000 1000 "$((1000 - t))" )"
	local tmp2="$(vec3_mulf 500 700 1000 "$t")"
	vec3_add $tmp1 $tmp2
}
