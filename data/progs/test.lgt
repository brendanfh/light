$mem_1 = 0
$mem_2 = 1

//Dummy function that doesn't do much
#test {
	!say($mem_1 + $mem_2)
}

while $mem_2 < 100000 {
	$mem_3 = $mem_1 + $mem_2
	$mem_1 = $mem_2
	$mem_2 = $mem_3
	!say($mem_3, $mem_2, $mem_2 == $mem_3)
}

if !in_bounds($pos_x + 1, $pos_y) {
	!test()
}

!redraw()