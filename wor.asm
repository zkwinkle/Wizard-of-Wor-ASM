.eqv GENID 1 # pseudo-random generator id
.eqv VISIBILITYTIME 180 # counter for how long enemies should stay visible, 180 = 9s (?)
.eqv ENEMYOFFSET 8 # if this is change the calc of $s1 in 'SpawnEnemy:' must be changed
.data
	# Colors
	colorOne:		.word 0x00ff8000
	colorTwo:		.word 0x00c00080
	whiteColor:		.word 0x00ffffff
	backgroundColor:	.word 0x00000000
	blueColor:		.word 0x001c57fe
	redColor:		.word 0x00de1a1a
	enemyGreenColor:	.word 0x00045d0d
	enemyRedColor:		.word 0x00a00000
	enemyPurpleColor:	.word 0x003a0e73
	enemyBlueColor:		.word 0x000e2973

	# Level info
	lvl:			.word 0  # Denotes the current lvl, 1-3

	# Player info
	playerDir:		.word 0 # 0=up, 1=down, 2=right, 3=left
	playerX:		.word 0
	playerY:		.word 0
	playerShoot:		.word 0 # 0 = no shot active, 1 = shot active
	lives:			.word 0
	playerState:		.word 0 # 0=INITIAL, 1=MOVING, 2=STATIC
	kills:			.word 0

	# Shot info
	shotDir:		.word 0 # same as playerDir
	shotX:			.word 0
	shotY:			.word 0

	# Enemy
	EnemiesSpawned:		.word 0
	Active:			.word 0 # 0=inactive, 1=active
	EnemyColor:		.word 0 # 0=green, 1=red, 2=purple, 3=blue
	EnemyDir:		.word 0 # 0=up, 1=down, 2=right, 3=left
	EnemyX:			.word 0
	EnemyY:			.word 0
	Visible:		.word 0
	VisibilityTimer:	.word 0
	MobilityTimer:		.word 0

	# For more than one enemy the data is stored in the same scheme as above in the static data
	# But every enemy's data is offset by 8, For example:
	# enemy 0's Active is offset by 0
	# enemy 1's Active is offset by 8*4
	# enemy 2's Active is offset by 16*4...

	# Maximum of 8 enemies

.text

NewGame:
	jal ClearBoard

	Title:
		lw $a2, whiteColor
	
		# W
		li $a0, 14
		li $a1, 2
		jal DrawW

		# WI
		li $a0, 22
		li $a1, 2
		addi $a3, $a1, 7
		jal DrawVerticalLine

		# WIZ
		li $a0, 24
		li $a1, 2
		jal DrawZ

		# WIZA
		li $a0, 31
		li $a1, 2
		jal DrawA

		# WIZAR
		li $a0, 38
		li $a1, 2
		jal DrawR

		# WIZARD
		li $a0, 44
		li $a1, 2
		jal DrawD

		# WIZARD O
		li $a0, 13
		li $a1, 13
		jal DrawO

		# WIZARD OF
		li $a0, 20
		li $a1, 13
		jal DrawF
		
		# WIZARD OF W
		li $a0, 30
		li $a1, 13
		jal DrawW
		
		# WIZARD OF WO
		li $a0, 38
		li $a1, 13
		jal DrawO
		
		# WIZARD OF WOR
		li $a0, 45
		li $a1, 13
		jal DrawR
	
	Press1or2:
		lw $a2, blueColor
	
		li $a0, 44
		li $a1, 25
		li $a3, 29
		jal DrawVerticalLine
		
		li $a0, 26
		jal DrawVerticalLine
		
		li $a0, 28
		jal DrawVerticalLine
		
		li $a0, 30
		jal DrawVerticalLine
		
		li $a0, 21
		jal DrawVerticalLine
		
		li $a3, 24
		jal DrawHorizontalLine
		
		li $a1, 27
		jal DrawHorizontalLine
		
		li $a0, 24
		li $a1, 26
		li $a3, 27
		jal DrawVerticalLine
		
		li $a0, 27
		li $a1, 25
		li $a3, 27
		jal DrawVerticalLine
		
		li $a0, 31
		li $a1, 27
		jal DrawPoint
		
		li $a1, 29
		jal DrawPoint
		
		li $a1, 25
		jal DrawPoint
		
		li $a0, 33 
		li $a1, 29
		li $a3, 35
		jal DrawHorizontalLine
		
		li $a0, 33
		li $a1, 27
		jal DrawHorizontalLine
		
		li $a1, 25
		jal DrawHorizontalLine
		
		li $a1, 26
		jal DrawPoint
		
		li $a0, 35
		li $a1, 28
		jal DrawPoint
		
		li $a0, 31
		li $a1, 25
		jal DrawPoint
		
		li $a0, 43
		li $a1, 26
		jal DrawPoint
		
		li $a1, 29
		li $a3, 45
		jal DrawHorizontalLine

		li $a0, 37
		li $a1, 29
		li $a3, 39
		jal DrawHorizontalLine
	
		li $a1, 27
		jal DrawHorizontalLine
		
		li $a1, 25
		li $a3, 39
		jal DrawHorizontalLine
	
		li $a1, 26
		jal DrawPoint
	
		li $a0, 39
		li $a1, 28
		jal DrawPoint
		
		li $a1, 26
		lw $a2, backgroundColor
		jal DrawPoint
		
		li $a0, 28
		li $a1, 27
		jal DrawPoint
		
		li $a0, 53
		li $a1, 26
		jal DrawPoint
		
		li $a0, 27
		jal DrawPoint
		
startWait:
	lw $t1, 0xFFFF0004		# check to see which key has been pressed
	beq $t1, 0x00000031, BeginGame # 1 pressed
	
	li $a0, 250	#
	li $v0, 32	# pause for 250 milisec
	syscall		#
	
	j startWait    # Jump back to the top of the wait loop
		
BeginGame:
	sw $zero, 0xFFFF0000		# clear the button pushed bit
	li $t1, 1
	sw $t1, lvl
	# initialize random seed based on time
	li $v0, 30
	syscall # get time
	move $a1, $a0 # move low order time into a1
	li $a0, GENID
	li $v0, 40
	syscall

	# Set player lives
	li $t0, 3
	sw $t0, lives
		

# $s0 se usa en standby, en MovePlayer, en SpawnEnemy y en MoveEnemies
# $s1 se usa en SpawnEnemy y en MoveEnemies
# $s2 se usa en el loop inicial de spawnear enemigos iniciales (spawnInitialEnemies) y en MoveEnemies
# $s3 se usa en MoveEnemies
# $s6 guarda la cantidad de enemigos iniciales
# $s7 guarda el counter/timer para spawns de enemigos
NewRound:
	# Initializa static data
	li $t0, 1
	sw $t0, playerDir
	li $t0, 50
	sw $t0, playerX
	li $t0, 25
	sw $t0, playerY
	li $t0, 0
	sw $t0, playerShoot
	li $t0, 0
	sw $t0, playerState
	li $t0, 0
	sw $t0, kills
	li $t0, 0
	sw $t0, EnemiesSpawned

	li $t1, 0 # i
	li $t2, 0 # offset
	resetEnemies:
		sll $t3, $t2, 2 # x4
		sw $zero, Active($t3) # store 0

		addi $t1, $t1, 1 # i++
		addi $t2, $t2, ENEMYOFFSET # +8 (atm of editing this)
		blt $t1, 8, resetEnemies
	
	# determine initial amount of enemies
	li $a1, 4
	jal RandomInt
	addi $a0, $a0, 2
	move $s6, $a0

	li $s2, 0
	spawnInitialEnemies:
		li $s7, 0 #set spawn timer to 0
		jal SpawnEnemy
		addi $s2, $s2, 1 # i++
		blt $s2, $s6, spawnInitialEnemies

	jal ClearBoard

	jal DrawMap
	
	li $a0, 200	#
	li $v0, 32	# pause for 0.2 second
		syscall		#

DrawObjects: 
	jal MovePlayer
	jal SpawnEnemy
	jal MoveEnemies

# Wait and read buttons
Begin_standby:	
		move $s0, $zero
		li $t0, 0x00000020 # how many ms of delay
	
Standby:
	blez $t0, EndStandby
	li $a0, 1	#
	li $v0, 32	# pause for 1 milisec
	syscall		#
	
	addi $t0, $t0, -1 		# decrement counter
	
	lw $t1, 0xFFFF0000		# check to see if a key has been pressed
	blez $t1, Standby
			
	jal AdjustDir			# see what was pushed
	sw $zero, 0xFFFF0000		# clear the button pushed bit
	li $s0, 1
	j Standby
EndStandby:		
	bne $s0, $zero, DrawObjects
	jal AdjustDir_none
	j DrawObjects
		
		
# AdjustDir  changes
AdjustDir: 
	lw $a0, 0xFFFF0004		# Load button pressed
		
AdjustDir_up:
	bne $a0, 119, AdjustDir_down  # w
	li $t0, 0	# up
	j AdjustDir_done		

AdjustDir_down:
	bne $a0, 115, AdjustDir_right	# s
	li $t0, 1	# down
	j AdjustDir_done

AdjustDir_right:
	bne $a0, 100, AdjustDir_left # d
	li $t0, 2	# right
	j AdjustDir_done

AdjustDir_left:
	bne $a0, 97, AdjustDir_shoot	# a
	li $t0, 3	# left
	j AdjustDir_done

AdjustDir_shoot:
	bne $a0, 32, AdjustDir_finish # spacebar
	j AdjustDir_finish # Don't set the dir to whatever's in $t0

AdjustDir_none:

	lw $t9, playerState
	bne $t9, 0, none_Regular

	j AdjustDir_finish # do nothing on initial state
	
	#none_Initial:
	#	# Change dir downwards (workaround)
	#	li $t0, 1
	#	j AdjustDir_done

	none_Regular:
		li $t1, 2
		sw $t1, playerState # save static state
		j AdjustDir_finish
	
AdjustDir_done:
	sw $t0, playerDir	#  Store dir
	lw $t9, playerState
	beq $t9, 0, AdjustDir_finish
	li $t1, 1
	sw $1, playerState
AdjustDir_finish:
	jr $ra				# Return

# $a0 contains x position, $a1 contains y position, $a2 contains the color	
DrawPoint:
	sll $t0, $a1, 6   # multiply y-coordinate by 64 (length of the field)
	addu $v0, $a0, $t0
	sll $v0, $v0, 2
	addu $v0, $v0, $gp
	sw $a2, ($v0)		# draw the color to the location
	
	jr $ra

# $a0 the x starting coordinate
# $a1 the y coordinate
# $a2 the color
# $a3 the x ending coordinate
DrawHorizontalLine:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	sub $t9, $a3, $a0
	move $t1, $a0
	
	HorizontalLoop:
		
		add $a0, $t1, $t9
		jal DrawPoint
		addi $t9, $t9, -1
		
		bge $t9, 0, HorizontalLoop
	
	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra
		
# $a0 the x coordinate
# $a1 the y starting coordinate
# $a2 the color
# $a3 the y ending coordinate
DrawVerticalLine:

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	sub $t9, $a3, $a1
	move $t1, $a1
		
	VerticalLoop:
		
		add $a1, $t1, $t9
		jal DrawPoint
		addi $t9, $t9, -1
		
		bge $t9, 0, VerticalLoop
		
	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4
	
	jr $ra
		
DrawMap:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $a2, redColor

	# main rectangle
	li $a0, 9
	li $a1, 0
	li $a3, 53
	jal DrawHorizontalLine

	li $a1, 24
	jal DrawHorizontalLine

	li $a1, 0
	li $a3, 24
	jal DrawVerticalLine
	
	li $a0, 53
	jal DrawVerticalLine

	li $a0, 4
	li $a1, 8
	li $a3, 9
	jal DrawHorizontalLine

	li $a1, 12
	jal DrawHorizontalLine

	li $a0, 53
	li $a1, 8
	li $a3, 58
	jal DrawHorizontalLine

	li $a1, 12
	jal DrawHorizontalLine

	# remove edge from warp gates
	lw $a2, backgroundColor
	li $a0, 9
	li $a1, 9
	li $a3, 11
	jal DrawVerticalLine

	li $a0, 53
	jal DrawVerticalLine

	# remove player pod's gate
	li $a0, 50
	li $a1, 24
	li $a3, 52
	jal DrawHorizontalLine

	# left top object
	lw $a2, redColor

	li $a0, 13
	li $a1, 4
	li $a3, 17
	jal DrawHorizontalLine

	li $a1, 12
	jal DrawHorizontalLine

	li $a0, 17
	li $a1, 4
	li $a3, 12
	jal DrawVerticalLine

	# right top object vertical
	li $a0, 45
	jal DrawVerticalLine

	# middle top-top verticals
	li $a0, 29
	li $a3, 8
	jal DrawVerticalLine

	li $a0, 33
	jal DrawVerticalLine

	# right top horizontals
	li $a0, 45
	li $a1, 4
	li $a3, 49
	jal DrawHorizontalLine

	li $a1, 12
	jal DrawHorizontalLine

	# middle top horizontals
	li $a0, 21
	li $a1, 8
	li $a3, 29
	jal DrawHorizontalLine

	li $a0, 33
	li $a1, 8
	li $a3, 41
	jal DrawHorizontalLine

	# middle top-low verticals
	li $a0, 21
	li $a1, 8
	li $a3, 12
	jal DrawVerticalLine

	li $a0, 41
	jal DrawVerticalLine

	# middle low-top verticals
	li $a0, 25
	li $a1, 12
	li $a3, 16
	jal DrawVerticalLine

	li $a0, 37
	jal DrawVerticalLine

	# middle low-low verticals
	li $a0, 17
	li $a1, 16
	li $a3, 20
	jal DrawVerticalLine

	li $a0, 45
	jal DrawVerticalLine

	# middle low horizontals
	li $a0, 17
	li $a1, 16
	li $a3, 25
	jal DrawHorizontalLine

	li $a0, 37
	li $a3, 45
	jal DrawHorizontalLine

	# radar rectangle
	li $a0, 25
	li $a1, 25
	li $a3, 31
	jal DrawVerticalLine

	li $a0, 37
	jal DrawVerticalLine

	li $a0, 25
	li $a1, 31
	li $a3, 37
	jal DrawHorizontalLine

	# player pod
	li $a0, 49
	li $a1, 25
	li $a3, 28
	jal DrawVerticalLine

	li $a0, 53
	jal DrawVerticalLine

	li $a0, 49
	li $a1, 28
	li $a3, 53
	jal DrawHorizontalLine

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# $a0 x coordinate
# $a1 y coordinate
# $a2 size (assumes square)
# $v0 = 1 if collision, = 0 if no collision
CheckWallCollisions:
	add $t9, $a1, $a2
	add $t8, $a0, $a2
	# top edge
	slti $v0, $a1, 1
	bne $v0, $zero, wallColDone

	# bottom edge
	li $t0, 24
	slt $v0, $t0, $t9
	bne $v0, $zero, wallColDone

	# right edge
	li $t0, 53
	slt $v0, $t0, $t8

	li $t0, 12 # check for gate height
	slt $t2, $t0, $t9 # revisar si pega abajo
	slti $t3, $a1, 9 # revisar si pega arriba
	or $t4, $t2, $t3
	and $v0, $v0, $t4 # solo es colisión si pega con el eje x y no está alineado con el gate
	bne $v0, $zero, wallColDone


	# left edge
	slti $v0, $a0, 10

	li $t0, 12 # check for gate height
	slt $t2, $t0, $t9 # revisar si pega abajo
	slti $t3, $a1, 9 # revisar si pega arriba
	or $t4, $t2, $t3
	and $v0, $v0, $t4 # solo es colisión si pega con el eje x y no está alineado con el gate
	bne $v0, $zero, wallColDone

	# top left object
		# top horizontal
		slti $t2, $a1, 5
		slti $t3, $t9, 5
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 18
		slti $t6, $t8, 14
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# bottom horizontal
		slti $t2, $a1, 13
		slti $t3, $t9, 13
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# vertical
		slti $t2, $a1, 13
		slti $t3, $t9, 5
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 18
		slti $t6, $t8, 18
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
	# top right object
		# top horizontal
		slti $t2, $a1, 5
		slti $t3, $t9, 5
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 50
		slti $t6, $t8, 46
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# bottom horizontal
		slti $t2, $a1, 13
		slti $t3, $t9, 13
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# vertical
		slti $t2, $a1, 13
		slti $t3, $t9, 5
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 46
		slti $t6, $t8, 46
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
	# top mid-left object
		# top vertical
		slti $t2, $a1, 9
		slti $t3, $t9, 5
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 30
		slti $t6, $t8, 30
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# bottom vertical
		slti $t2, $a1, 13
		slti $t3, $t9, 9
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 22
		slti $t6, $t8, 22
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# horizontal
		slti $t2, $a1, 9
		slti $t3, $t9, 9
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 30
		slti $t6, $t8, 22
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
	# bottom mid-left object
		# top vertical
		slti $t2, $a1, 17
		slti $t3, $t9, 13
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 26
		slti $t6, $t8, 26
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# bottom vertical
		slti $t2, $a1, 21
		slti $t3, $t9, 17
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 18
		slti $t6, $t8, 18
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# horizontal
		slti $t2, $a1, 17
		slti $t3, $t9, 17
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 26
		slti $t6, $t8, 18
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
	# top mid-right object
		# top vertical
		slti $t2, $a1, 9
		slti $t3, $t9, 5
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 34
		slti $t6, $t8, 34
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# bottom vertical
		slti $t2, $a1, 13
		slti $t3, $t9, 9
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 42
		slti $t6, $t8, 42
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# horizontal
		slti $t2, $a1, 9
		slti $t3, $t9, 9
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 42
		slti $t6, $t8, 34
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
	# bottom mid-right object
		# top vertical
		slti $t2, $a1, 17
		slti $t3, $t9, 13
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 38
		slti $t6, $t8, 38
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# bottom vertical
		slti $t2, $a1, 21
		slti $t3, $t9, 17
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 46
		slti $t6, $t8, 46
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# horizontal
		slti $t2, $a1, 17
		slti $t3, $t9, 17
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 46
		slti $t6, $t8, 38
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
	wallColDone:
		jr $ra

MovePlayer:
	# objective: erase player's position, look at the player's direction, increase position in the right direction, check collisions with walls and possibly step back

	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# Check state
	lw $t8, playerState 
	beq $t8, 0,  pInitial
	beq $t8, 1,  pMoving
	beq $t8, 2,  pStatic

	pMoving:
		lw $t9, playerDir
		beq $t9, 0, pMUp
		beq $t9, 1, pMDown
		beq $t9, 2, pMRight
		beq $t9, 3, pMLeft

		# pM = player Move
		pMUp:
			lw $a0, playerX
			lw $s0, playerY
			addi $s0, $s0, -1
			move $a1, $s0
			li $a2, 3
			jal CheckWallCollisions
			bne $v0, $zero, pMCollide

			sw $s0, playerY

			# paint back dot
			lw $a2, whiteColor
			addi $a0, $a0, 1
			addi $a1, $s0, 2
			jal DrawPoint

			# erase mid dot
			lw $a2, backgroundColor
			addi $a1, $a1, -1
			jal DrawPoint

			# erase below
			addi $a0, $a0, -1
			addi $a1, $a1, 2
			addi $a3, $a0, 2
			jal DrawHorizontalLine

			j pMoveDone
		pMDown:
			lw $a0, playerX
			lw $s0, playerY
			addi $s0, $s0, 1
			move $a1, $s0
			li $a2, 3
			jal CheckWallCollisions
			bne $v0, $zero, pMCollide

			sw $s0, playerY

			# paint back dot
			lw $a2, whiteColor
			addi $a0, $a0, 1
			addi $a1, $s0, 0
			jal DrawPoint

			# erase mid dot
			lw $a2, backgroundColor
			addi $a1, $a1, 1
			jal DrawPoint

			# erase above
			addi $a0, $a0, -1
			addi $a1, $a1, -2
			addi $a3, $a0, 2
			jal DrawHorizontalLine

			j pMoveDone
		pMRight:
			lw $a1, playerY
			lw $s0, playerX
			addi $s0, $s0, 1
			move $a0, $s0
			li $a2, 3
			jal CheckWallCollisions
			bne $v0, $zero, pMCollide

			# check if player is warping to left
			slti $t0, $a0, 57
			beq $t0, $zero, warpLeft

			# if not continue as usual
			sw $s0, playerX

			# paint back dot
			lw $a2, whiteColor
			addi $a1, $a1, 1
			addi $a0, $s0, 0
			jal DrawPoint

			# erase mid dot
			lw $a2, backgroundColor
			addi $a0, $a0, 1
			jal DrawPoint

			# erase left
			addi $a0, $a0, -2
			addi $a1, $a1, -1
			addi $a3, $a1, 2
			jal DrawVerticalLine

			j pMoveDone
		pMLeft:
			lw $a1, playerY
			lw $s0, playerX
			addi $s0, $s0, -1
			move $a0, $s0
			li $a2, 3
			jal CheckWallCollisions
			bne $v0, $zero, pMCollide

			# check if player is warping to right
			slti $t0, $a0, 4
			bne $t0, $zero, warpRight

			sw $s0, playerX

			# paint back dot
			lw $a2, whiteColor
			addi $a1, $a1, 1
			addi $a0, $s0, 2
			jal DrawPoint

			# erase mid dot
			lw $a2, backgroundColor
			addi $a0, $a0, -1
			jal DrawPoint

			# erase right
			addi $a0, $a0, 2
			addi $a1, $a1, -1
			addi $a3, $a1, 2
			jal DrawVerticalLine

			j pMoveDone

		pMCollide:
			# erase front dot
			lw $a2, backgroundColor
			addi $a1, $a1, 1
			addi $a0, $a0, 1
			jal DrawPoint
			j pMoveDone

		warpLeft:
			# remove trace from right
			lw $a2, backgroundColor
			li $a0, 56
			li $a1, 9
			addi $a3, $a0, 3
			jal DrawHorizontalLine
			addi $a1, $a1, 1
			jal DrawHorizontalLine
			addi $a1, $a1, 1
			jal DrawHorizontalLine

			# update xpos
			li $t0, 4
			sw $t0, playerX

			j pMoveDone
		warpRight:
			# remove trace from left
			lw $a2, backgroundColor
			li $a0, 3
			li $a1, 9
			addi $a3, $a1, 3
			jal DrawHorizontalLine
			addi $a1, $a1, 1
			jal DrawHorizontalLine
			addi $a1, $a1, 1
			jal DrawHorizontalLine

			# update xpos
			li $t0, 56
			sw $t0, playerX

			j pMoveDone


	pInitial:
		lw $t9, playerDir
		bne $t9, 0, adjustPInitDir #must be moving up to move
		lw $t0, playerY
		addi $t0, $t0, -1 #move 2x speed
		sw $t0, playerY

		# erase below
		lw $a2, backgroundColor
		lw $a0, playerX
		addi $a1, $t0, 3
		addi $a3, $a0, 2
		jal DrawHorizontalLine

		lw $t0, playerY
		ble $t0, 21, pOverGate
		
		# change dir to up for drawing purposes 
		j pMoveDone

		adjustPInitDir:
			sw $zero, playerDir
			lw $a2, whiteColor
			jal DrawPlayer
			li $t3, 1
			sw $t3, playerDir
			j pMoveFinish

		pOverGate:
			addi $t1, $zero, 2
			sw $t1, playerState # Change state to static

			# Close gate
			lw $a2, redColor
			li $a0, 50
			li $a1, 24
			li $a3, 52
			jal DrawHorizontalLine

	pStatic:
		# do nothing

	pMoveDone:
		lw $a2, whiteColor
		jal DrawPlayer

	pMoveFinish:
		lw $ra, 0($sp)		# put return back
		addi $sp, $sp, 4

		jr $ra

# $a2: player's color
DrawPlayer:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $a0, playerX
	lw $a1, playerY

	lw $t9, playerDir
	beq $t9, 0, PDUp
	beq $t9, 1, PDDown
	beq $t9, 2, PDRight
	beq $t9, 3, PDLeft
		
	# PD = Player Draw
	PDUp:
		addi $a3, $a1, 2
		jal DrawVerticalLine
		addi $a0, $a0, 2
		jal DrawVerticalLine
		addi $a0, $a0, -1
		addi $a1, $a1, 2
		jal DrawPoint
		j PDDone
	PDDown:
		addi $a3, $a1, 2
		jal DrawVerticalLine
		addi $a0, $a0, 1
		jal DrawPoint
		addi $a0, $a0, 1
		jal DrawVerticalLine
		j PDDone
	PDRight:
		addi $a3, $a0, 2
		jal DrawHorizontalLine
		addi $a1, $a1, 1
		jal DrawPoint
		addi $a1, $a1, 1
		jal DrawHorizontalLine
		j PDDone
	PDLeft:
		addi $a3, $a0, 2
		jal DrawHorizontalLine
		addi $a1, $a1, 2
		jal DrawHorizontalLine
		addi $a1, $a1, -1
		addi $a0, $a0, 2
		jal DrawPoint
		j PDDone
	PDDone:

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# $a1, upper bound exclusive
# $a0, receives random int
RandomInt:
	li $v0, 42
	li $a0, GENID
	syscall
	jr $ra

# $a0, enemy color (0-3)
# $v0, return's counter
CalcMobilityTime:
	# maps $a0=0-3 to $v0=[7, 5, 3, 2]
	li $v0, 3
	sub $v0, $v0, $a0 # $v0 = 3-color
	sll $v0, $v0, 1 # x2
	bne $v0, $zero, add1 # add 2 if 0, add 1 to others
	add2:
		addi $v0, $v0, 1
	add1:
		addi $v0, $v0, 1
	jr $ra


SpawnEnemy:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# Max number of spawns = 8
	lw $s0, EnemiesSpawned
	bge $s0, 9, FinishSpawn

	# Check spawn timer
	bgtz $s7, DecreaseSpawnTimer

	bge $s0, $s6, RandomColor
	InitialGreens:
		move $t1, $zero
		j ColorChosen

	RandomColor:
		# generate random color
		li $a1, 4
		jal RandomInt
		move $t1, $a0

	ColorChosen:
		# use the # of enemy that is being spawned and update it's color, activeness, initial dir, inital x and initial y
		
		sll $s1, $s0, 3 #multiply by 8 (because of enemy offset)
		sll $s1, $s1, 2 # x4 because of memory addressing
		# Save color
		sw $t1, EnemyColor($s1)

		# Update mobility timer
		move $a0, $t1
		jal CalcMobilityTime
		sw $v0, MobilityTimer($s1)

		# Turn on active 
		li $t0, 1
		sw $t0, Active($s1)

		# generate random dir
		li $a1, 4
		jal RandomInt
		move $t2, $a0

		sw $t2, EnemyDir($s1)

		# generate random X
		li $a1, 11
		jal RandomInt
		move $t3, $a0
		sll $t3, $t3, 2 # multiply tile by 4
		addi $t3, $t3, 10 # add 10 min bound for horizontal tile

		sw $t3, EnemyX($s1)

		# generate random Y
		li $a1, 6
		jal RandomInt
		move $t4, $a0
		sll $t4, $t4, 2 # multiply tile by 4
		addi $t4, $t4, 1 # add 1 min bound for vertical tile

		sw $t4, EnemyY($s1)

		# make visible
		li $t5, 1
		sw $t5, Visible($s1)

		# update visibility timer
		li $t6, VISIBILITYTIME
		sw $t6, VisibilityTimer($s1)

		# Reset spawn timer 2-5s (40-100)
		li $a1, 60
		jal RandomInt
		addi $a0, $a0, 40
		move $s7, $a0

		# Increment enemies spawned
		addi $s0, $s0, 1
		sw $s0, EnemiesSpawned

		j FinishSpawn

	DecreaseSpawnTimer:
		addi $s7, $s7, -1

	FinishSpawn:
		lw $ra, 0($sp)		# put return back
		addi $sp, $sp, 4

		jr $ra

MoveEnemies:
	# objective: check enemy activeness, then check/update its mobility timer, look at the enemie's direction, erase previous position, increase position in the right direction, check collisions with walls and possibly step back

	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $s1, 0 # i (counter)
	li $s3, 0 # offset
	M1E: # M1E = Move 1 Enemy
		sll $s2, $s3, 2 # x4
		lw $t0, Active($s2) # get activeness
		beq $t0, 0, SkipM1E

		# "invis timer and stuff"

		# "before actually moving check for being shot"

		# Check mobility timer
		lw $t1, MobilityTimer($s2)
		bgtz $t1, DecreaseMobilityTimer
	
		# Check Dir
		lw $t9, EnemyDir($s2)
		beq $t9, 0, eMUp
		beq $t9, 1, eMDown
		beq $t9, 2, eMRight
		beq $t9, 3, eMLeft

		eMUp:
			lw $a0, EnemyX($s2)
			lw $s0, EnemyY($s2)
			addi $s0, $s0, -1
			move $a1, $s0
			li $a2, 3
			jal CheckWallCollisions
			bne $v0, $zero, eMCollide

			# erase previous X
			lw $a0, EnemyX($s2)
			lw $a1, EnemyY($s2)
			lw $a2, backgroundColor
			jal DrawEnemy

			sw $s0, EnemyY($s2) #save new pos

			j eCheckGrid

                eMDown:
			lw $a0, EnemyX($s2)
			lw $s0, EnemyY($s2)
			addi $s0, $s0, 1
			move $a1, $s0
			li $a2, 3
			jal CheckWallCollisions
			bne $v0, $zero, eMCollide

			# erase previous X
			lw $a0, EnemyX($s2)
			lw $a1, EnemyY($s2)
			lw $a2, backgroundColor
			jal DrawEnemy

			sw $s0, EnemyY($s2) # new pos

			j eCheckGrid
                eMRight:
			lw $s0, EnemyX($s2)
			lw $a1, EnemyY($s2)
			addi $s0, $s0, 1
			move $a0, $s0
			li $a2, 3
			jal CheckWallCollisions
			bne $v0, $zero, eMCollide

			# erase previous X
			lw $a0, EnemyX($s2)
			lw $a1, EnemyY($s2)
			lw $a2, backgroundColor
			jal DrawEnemy

			# check if enemy is warping to left
			lw $a0, EnemyX($s2)
			slti $t0, $a0, 57
			beq $t0, $zero, eWarpLeft

			sw $s0, EnemyX($s2) # new pos

			j eCheckGrid
                eMLeft:
			lw $s0, EnemyX($s2)
			lw $a1, EnemyY($s2)
			addi $s0, $s0, -1
			move $a0, $s0
			li $a2, 3
			jal CheckWallCollisions
			bne $v0, $zero, eMCollide

			# erase previous X
			lw $a0, EnemyX($s2)
			lw $a1, EnemyY($s2)
			lw $a2, backgroundColor
			jal DrawEnemy

			# check if enemy is warping to right
			lw $a0, EnemyX($s2)
			slti $t0, $a0, 4
			bne $t0, $zero, eWarpRight

			sw $s0, EnemyX($s2) # new pos

			j eCheckGrid

		eCheckGrid:
			# check if enemy's pos aligns with the grid and randomly maybe switch dirs

			# check if X multiple of 4 + 2
			lw $t0, EnemyX($s2)
			addi $t2, $t0, -2
			srl $t1, $t2, 2
			sll $t1, $t1, 2
			bne $t1, $t2, eMoveDone

			# check if Y multiple of 4 + 1
			lw $t0, EnemyY($s2)
			addi $t2, $t0, -1
			srl $t1, $t2, 2
			sll $t1, $t1, 2
			bne $t1, $t2, eMoveDone

			# if enemy aligned with grid then random chance to turn
			# 1/4 chance
			li $a1, 4
			jal RandomInt
			beq $a0, $zero, eChangeDir

			j eMoveDone

		eMCollide:
			# change dir
		eChangeDir:
			lw $t0, EnemyDir($s2) # get current dir
			eChangeDirLoop: # make sure it doesn't repick the same one
				li $a1, 4
				jal RandomInt
				beq $a0, $t0, eChangeDirLoop
			
			sw $a0, EnemyDir($s2) # new dir
			j eMoveDone

		eWarpLeft:
			# update xpos
			li $t0, 4
			sw $t0, EnemyX($s2) # new pos

			j eMoveDone

		eWarpRight:
			# update xpos
			li $t0, 56
			sw $t0, EnemyX($s2) # new pos

			j eMoveDone

		eMoveDone:
			# get color
			lw $a0, EnemyColor($s2)
			
			# Reset mobility timer
			jal CalcMobilityTime
			sw $v0, MobilityTimer($s2)
			j SkipM1E

		DecreaseMobilityTimer:
			lw $t1, MobilityTimer($s2)
			addi $t1, $t1, -1
			sw $t1, MobilityTimer($s2)

		SkipM1E:
			addi $s1, $s1, 1 
			addi $s3, $s3, ENEMYOFFSET
			blt $s1, 8, M1E

	jal DrawEnemies
	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

DrawEnemies:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $t1, 0 # i (counter)
	li $t2, 0 # offset
	D1E: # D1E = Draw 1 Enemy
		sll $t3, $t2, 2 # x4
		lw $t0, Active($t3) # get activeness
		beq $t0, 0, SkipD1E

		lw $t0, Visible($t3) # get visibility
		beq $t0, 0, SkipD1E

		lw $a0, EnemyX($t3)
		lw $a1, EnemyY($t3)

		# get color
		lw $t4, EnemyColor($t3)
		beq $t4, 0, IsGreen
		beq $t4, 1, IsRed
		beq $t4, 2, IsPurple
		beq $t4, 3, IsBlue
		
		IsGreen:
			lw $a2, enemyGreenColor
			j IsColorDone
		IsRed:
			lw $a2, enemyRedColor
			j IsColorDone
		IsPurple:
			lw $a2, enemyPurpleColor
			j IsColorDone
		IsBlue:
			lw $a2, enemyBlueColor
		IsColorDone:

		# make space in stack for counters
		addi $sp, $sp, -8
		sw $t1, 4($sp)
		sw $t2, 0($sp)

		jal DrawEnemy

		# restore counters
		lw $t1, 4($sp)
		lw $t2, 0($sp)
		addi $sp, $sp, 8

	SkipD1E:
		addi $t1, $t1, 1 
		addi $t2, $t2, ENEMYOFFSET
		blt $t1, 8, D1E

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# $a0: enemy x
# $a1: enemy y
# $a2: enemy color
DrawEnemy:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal DrawPoint
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal DrawPoint
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal DrawPoint
	addi $a1, $a1, -2
	jal DrawPoint
	addi $a1, $a1, 2
	addi $a0, $a0, -2
	jal DrawPoint

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# $a0 x starting coord
# $a1 y coordinate
# $a2 color
DrawA:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	addi $a3, $a0, 5
	jal DrawHorizontalLine

	addi $a1, $a1, 4
	jal DrawHorizontalLine

	addi $a1, $a1, -4
	addi $a3, $a1, 7
	jal DrawVerticalLine

	addi $a0, $a0, 5
	jal DrawVerticalLine

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# $a0 x starting coord
# $a1 y coordinate
# $a2 color
DrawD:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	addi $a3, $a0, 3
	jal DrawHorizontalLine

	addi $a1, $a1, 7
	jal DrawHorizontalLine

	addi $a1, $a1, -7
	addi $a3, $a1, 7
	jal DrawVerticalLine

	addi $a0, $a0, 4
	addi $a1, $a1, 1
	addi $a3, $a3, -1
	jal DrawVerticalLine

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# $a0 x starting coord
# $a1 y coordinate
# $a2 color
DrawF:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	addi $a3, $a0, 5
	jal DrawHorizontalLine

	addi $a3, $a1, 7
	jal DrawVerticalLine

	addi $a1, $a1, 3
	addi $a3, $a0, 4
	jal DrawHorizontalLine

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# $a0 x starting coord
# $a1 y coordinate
# $a2 color
DrawO:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	addi $a3, $a0, 5
	jal DrawHorizontalLine

	addi $a1, $a1, 7
	jal DrawHorizontalLine

	addi $a1, $a1, -7
	addi $a3, $a1, 7
	jal DrawVerticalLine

	addi $a0, $a0, 5
	jal DrawVerticalLine

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# $a0 x starting coord
# $a1 y coordinate
# $a2 color
DrawR:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	addi $a3, $a0, 4
	jal DrawHorizontalLine

	addi $a1, $a1, 3
	jal DrawHorizontalLine

	addi $a1, $a1, -3
	addi $a3, $a1, 7
	jal DrawVerticalLine

	addi $a0, $a0, 4
	addi $a3, $a1, 3
	jal DrawVerticalLine

	addi $a0, $a0, -2
	addi $a1, $a1, 4
	jal DrawPoint
	
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal DrawPoint

	addi $a1, $a1, 1
	jal DrawPoint

	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal DrawPoint

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# $a0 x starting coord
# $a1 y coordinate
# $a2 color
DrawW:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	addi $a3, $a1, 5
	jal DrawVerticalLine

	addi $a0, $a0, 1
	addi $a1, $a1, 6
	jal DrawPoint

	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal DrawPoint

	addi $a0, $a0, 1
	addi $a1, $a1, -5
	addi $a3, $a1, 4
	jal DrawVerticalLine

	addi $a0, $a0, 1
	addi $a1, $a1, 5
	jal DrawPoint

	addi $a0, $a0, 1
	addi $a1, $a1, -1
	jal DrawPoint

	addi $a0, $a0, 1
	addi $a1, $a1, -6
	addi $a3, $a1, 5
	jal DrawVerticalLine
	

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# $a0 x starting coord
# $a1 y coordinate
# $a2 color
DrawZ:
	# make space in stack for return address
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $a3, $a0, 5
	jal DrawHorizontalLine

	addi $a1, $a1, 7
	jal DrawHorizontalLine

	addi $a1, $a1, -1
	addi $t9, $zero, 6

	DiagonalLoop:
		jal DrawPoint
		addi $a1, $a1, -1
		addi $a0, $a0, 1
		addi $t9, $t9, -1

		bne $t9, $zero, DiagonalLoop

	lw $ra, 0($sp)		# put return back
	addi $sp, $sp, 4

	jr $ra

# Makes the entire bitmap display the background color (black)
ClearBoard:
	lw $t0, backgroundColor
	li $t1, 8192 # The number of pixels in the display
	StartCLoop:
		subi $t1, $t1, 4
		addu $t2, $t1, $gp
		sw $t0, ($t2)
		beqz $t1, EndCLoop
		j StartCLoop
	EndCLoop:
		jr $ra

WaitForReset:		
	li $a0, 10 	#
	li $v0, 32	# pause for 10 milisec
	syscall		#
	
	lw $t0, 0xFFFF0000
	beq $t0, $zero, WaitForReset
	
	j Reset
		
Reset:		
	sw $zero, 0xFFFF0000	# Zeros the keypress words in memory
	sw $zero, 0xFFFF0004

	jal ClearBoard

	j NewGame
