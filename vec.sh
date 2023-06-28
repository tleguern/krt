vec3_add() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift
	local v2x="$1"; shift
	local v2y="$1"; shift
	local v2z="$1"

	echo "$(( v1x + v2x )) $(( v1y + v2y )) $(( v1z + v2z ))"
}

vec3_sub() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift
	local v2x="$1"; shift
	local v2y="$1"; shift
	local v2z="$1"

	echo "$(( v1x - v2x )) $(( v1y - v2y )) $(( v1z - v2z ))"
}

vec3_mul() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift
	local v2x="$1"; shift
	local v2y="$1"; shift
	local v2z="$1"

	echo "$(( v1x * v2x / 1000 )) $(( v1y * v2y / 1000 )) $(( v1z * v2z / 1000 ))"
}

vec3_mulf() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift
	local f="$1"

	echo "$(( v1x * f / 1000 )) $(( v1y * f / 1000 )) $(( v1z * f / 1000 ))"
}

vec3_div() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift
	local v2x="$1"; shift
	local v2y="$1"; shift
	local v2z="$1"

	echo "$(( v1x * 1000 / v2x )) $(( v1y * 1000 / v2y )) $(( v1z * 1000 / v2z ))"
}

vec3_divf() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift
	local f="$1"

	echo "$(( v1x * 1000 / f )) $(( v1y * 1000 / f )) $(( v1z * 1000 / f ))"
}

vec3_trunc() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift

	echo "$(( v1x / 1000 )) $(( v1y / 1000 )) $(( v1z / 1000 ))"
}

vec3_squared() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift

	echo "$(( v1x * v1x / 1000 )) $(( v1y * v1y / 1000 )) $(( v1z * v1z / 1000 ))"
}

vec3_sum() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift

	echo "$(( v1x + v1y + v1z ))"
}

vec3_dot() {
	vec3_sum $(vec3_mul $@)
}

vec3_cross() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift
	local v2x="$1"; shift
	local v2y="$1"; shift
	local v2z="$1"

	echo "$(( v1y * v2z - v1z * v2y )) $(( v1z * v2x - v1x * v2z)) $(( v1x * v2y - v1y * v2x ))"
}

vec3_unit_vector() {
	local v1x="$1"; shift
	local v1y="$1"; shift
	local v1z="$1"; shift

	local tmp1="$(vec3_squared $v1x $v1y $v1z)"
	local tmp2="$(vec3_sum $tmp1)"
	local tmp3="$(_sqrt $tmp2)"
	vec3_divf $v1x $v1y $v1z $tmp3
}
