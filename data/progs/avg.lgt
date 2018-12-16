
#FLOOD_WITH_RANDOM {
	$m6 = -1 + 256 * 256 * 256
	$m7 = !GET_WIDTH()
	$m8 = !GET_HEIGHT()

	$y = 0
	while $y < $m8 {
		$x = 0
		while $x < $m7 {
			!SET_COL(!RANDOM($m6))
			$x = $x + 1
		}	
		$y = $y + 1
	}
}

//change 1, 2, 3 4, 7, 8
#TAKE_AVERAGE {
	//Red, Green and Blue Sum
	$m1 = 0
	$m2 = 0
	$m3 = 0
	//Count
	$m4 = 0

	$m7 = $x + 1
	$m8 = $y + 1	

	$y = $y - 1
	while $y <= $m8 {
		$x = $m7 - 2
		while $x <= $m7 {
			if !IN_BOUNDS($x, $y) {
				$m1 = $m1 + !GET_R()
				$m2 = $m2 + !GET_G()
				$m3 = $m3 + !GET_B()

				$m4 = $m4 + 1
			}

			$x = $x + 1
		}
		$y = $y + 1
	}
	$x = $x - 2
	$y = $y - 2

	if $m4 > 0 {
		$m1 = $m1 / $m4
		$m2 = $m2 / $m4
		$m3 = $m3 / $m4
		$m1 = $m1 * 256 * 256
		$m2 = $m2 * 256
		!SET_COL($m1 + $m2 + $m3)
	}
}

!FLOOD_WITH_RANDOM()

!SAY(!GET_WIDTH())
!SAY(!GET_HEIGHT())

$m5 = 30
while 1 {
	!RENDER()
	$m5 = $m5 - 1
	if $m5 <= 0 {
		$m5 = 30

		$y = 0
		while $y < !GET_HEIGHT() {
			$x = 0
			while $x < !GET_WIDTH() {
				!TAKE_AVERAGE()
				$x = $x + 1
			}
			$y = $y + 1
		}
	}
}
