//Assumes 128 by 128 board
#BOARD_WIDTH { !GET_WIDTH() }
#BOARD_HEIGHT { !GET_HEIGHT() }

#CELL_ALIVE { 255 }
#CELL_DEAD { 0 }

// Set up initial board
$y = 0
while $y < !BOARD_HEIGHT() {
	$x = 0
	while $x < !BOARD_WIDTH() {
		if !random(100) >= 50 {
			!set_r(!CELL_ALIVE())
		} else {
			!set_r(!CELL_DEAD())
		}
		$x = $x + 1
	}
	$y = $y + 1
}

#UPDATE_CURRENT {
	//Neighbor count
	$m1 = 0

	$x = $x - 1
	$y = $y - 1

	$m1 = $m1 + !get_a() == !CELL_ALIVE()
	$x = $x + 1
	$m1 = $m1 + !get_a() == !CELL_ALIVE()
	$x = $x + 1
	$m1 = $m1 + !get_a() == !CELL_ALIVE()
	$x = $x - 2
	$y = $y + 1
	$m1 = $m1 + !get_a() == !CELL_ALIVE()
	$x = $x + 2
	$m1 = $m1 + !get_a() == !CELL_ALIVE()
	$x = $x - 2
	$y = $y + 1
	$m1 = $m1 + !get_a() == !CELL_ALIVE()
	$x = $x + 1
	$m1 = $m1 + !get_a() == !CELL_ALIVE()
	$x = $x + 1
	$m1 = $m1 + !get_a() == !CELL_ALIVE()

	$x = $x - 1
	$y = $y - 1

	$m2 = !get_a() == !CELL_ALIVE()
	if $m2 {
		if ($m1 < 2) + ($m1 > 3) {
			!set_r(!CELL_DEAD())
		}
	} else {
		if $m1 == 3 {
			!set_r(!CELL_ALIVE())
		}
	}
}

#COPY_BOARD {
	$y = 0
	while $y < !BOARD_HEIGHT() {
		$x = 0
		while $x < !BOARD_WIDTH() {
			!set_a(!get_r())

			$x = $x + 1
		}
		$y = $y + 1
	}
}

//Big render / update loop
$m7 = 30
while 1 {
	//Draw the board
	!render()

	$m7 = $m7 - 1
	if $m7 <= 0 {
		$m7 = 1

		$y = 0
		while $y < !BOARD_HEIGHT() {
			$x = 0
			while $x < !BOARD_WIDTH() {
				!COPY_BOARD()
				$x = $x + 1
			}
			$y = $y + 1
		}

		$y = 0
		while $y < !BOARD_HEIGHT() {
			$x = 0
			while $x < !BOARD_WIDTH() {
				!UPDATE_CURRENT()
				$x = $x + 1
			}
			$y = $y + 1
		}
	}
}