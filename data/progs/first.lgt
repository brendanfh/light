$x = 0
$y = 10
$m8 = 1

#move_diag {
	$x = $x + $m8
	$y = $y + $m8
}

#swap_xy {
	$m1 = $x
	$x = $y
	$y = $m1
}

$m3 = 100
while $x <= !GET_WIDTH() {
	$m3 = $m3 + 4
	if $m3 >= 256 {
		$m3 = $m3 - 156
	}

	!set_col($m3)
	!move_diag()
	!swap_xy()
	!render()
}

$x = !GET_WIDTH() - 15
$y = !GET_HEIGHT() - 1
$m8 = 0 - 1

while $x >= 0 {
	!set_col(255)
	!move_diag()
	!render()
}

!say($x)
$m2 = if $x < 0 {
	1000
}
!say($m2)
