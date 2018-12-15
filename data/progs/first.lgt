$pos_x = 0
$pos_y = 10
$mem_8 = 1

#move_diag {
	$pos_x = $pos_x + $mem_8
	$pos_y = $pos_y + $mem_8
}

#swap_xy {
	$mem_1 = $pos_x
	$pos_x = $pos_y
	$pos_y = $mem_1
}

$mem_3 = 100
while $pos_x <= 255 {
	$mem_3 = $mem_3 + 4
	if $mem_3 >= 256 {
		$mem_3 = $mem_3 - 156
	}

	!set_col($pos_x, $pos_y, $mem_3)
	!move_diag()
	!swap_xy()
	!render()
}

$pos_x = 240
$pos_y = 255
$mem_8 = 0 - 1

while $pos_x >= 0 {
	!set_col($pos_x, $pos_y, 255)
	!move_diag()
	!render()
}

!say($pos_x)
$mem_2 = if $pos_x < 0 {
	1000
}
!say($mem_2)
