@push_pos() {
	$m1 = ($y * 256 * 256) + $x

	!step_to_linear(0)
	!step_to_linear(!get_col() + 1)

	!set_col($m1)

	!step_to_linear(0)
	!set_col(!get_col() + 1)

	$x = $m1 % (256 * 256)
	$y = $m1 / (256 * 256)
}

@pop_pos() {
	!step_to_linear(0)
	!step_to_linear(!get_col())
	$m1 = !get_col()
	//!set_col(16777215)

	!step_to_linear(0)
	!set_col(!get_col() - 1)
	$x = $m1 % (256 * 256)
	$y = $m1 / (256 * 256)
}

@get_stack_height() {
	!push_pos()
	!step_to_linear(0)
	$m2 = !get_col() - 1
	!pop_pos()
	$m2
}

//Fills memory with defaults
$y = 20
while $y < !get_height() {
	$x = 0
	while $x < !get_width() {
		!set_col(255)
		$x = $x + 1
	}
	$y = $y + 1
}


$x = 1
$y = 21
!push_pos()
!set_col(50)
while !get_stack_height() > 0 {
	!pop_pos()
	!push_pos()

	$m1 = 0
	$y = $y - 2	
	$m1 = $m1 + if !get_col() == 255 { 1 } else { 0 }
	$y = $y + 2
	$x = $x - 2
	$m1 = $m1 + if !get_col() == 255 { 1 } else { 0 }
	$x = $x + 4
	$m1 = $m1 + if !get_col() == 255 { 1 } else { 0 }
	$x = $x - 2
	$y = $y + 2
	$m1 = $m1 + if !get_col() == 255 { 1 } else { 0 }
	$y = $y - 2

	if $m1 {
		while 1 {
			//Random direction
			$m7 = !random(4)

			// dx and dy
			$m5 = $m6 = 0

			if $m7 == 0 { $m6 = -2 }
			if $m7 == 1 { $m5 =  2 }
			if $m7 == 2 { $m6 =  2 }
			if $m7 == 3 { $m5 = -2 }

			if !in_bounds($x + $m5, $y + $m6) {
				!push_pos()
				!push_pos()
				$x = $x + $m5
				$y = $y + $m6
				if !get_col() == 255 {
					!set_col(50)
					!pop_pos()
					$x = $x + $m5 / 2
					$y = $y + $m6 / 2
					!set_col(50)
					!pop_pos()
					$x = $x + $m5
					$y = $y + $m6
					!push_pos()
					break
				} else {
					!pop_pos()
					!pop_pos()
				}
			}
		}
	} else {
		!pop_pos()
	}
	!render()
}
