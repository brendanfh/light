$MEM_1 = 0
$MEM_2 = 1

WHILE $MEM_2 < 100000 DO
	$MEM_3 = $MEM_1 + $MEM_2
	$MEM_1 = $MEM_2
	$MEM_2 = $MEM_3
END