$mem_2 = 0
$mem_3 = 10000

while 1 {
	$pos_x = 0
	$pos_y = 0
	while $pos_y < 256 {
		$mem_1 = 20 * $pos_x + $mem_2 / 4
		$mem_1 = $mem_1 + $pos_y * $pos_x * 5
		!set_col($mem_1)
		!step_linear(1)
	}
	$mem_2 = $mem_2 + 1
	!render()

	$mem_3 = $mem_3 - 1
	if $mem_3 <= 0 {
		!halt()
	}
}

