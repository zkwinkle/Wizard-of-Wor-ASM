.data
	# Colors
	colorOne:		.word 0x00ff8000
	colorTwo:		.word 0x00c00080
	whiteColor:		.word 0x00ffffff
	backgroundColor:	.word 0x00000000
	blueColor:		.word 0x001c57fe
	redColor:		.word 0x00de1a1a

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
	visibilityTimer:	.word 0

	# For more than one enemy the data is stored in the same scheme as above in the static data
	# But every enemy's data is offset by 6, For example:
	# enemy 0's Active is offset by 0
	# enemy 1's Active is offset by 6*4
	# enemy 2's Active is offset by 12*4...

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
		

# $s0 se usa en standby y en MovePlayer
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
	li $t0, 3
	sw $t0, lives
	li $t0, 0
	sw $t0, playerState
	li $t0, 0
	sw $t0, kills
	li $t0, 0
	sw $t0, EnemiesSpawned

	li $t1, 8
	li $t2, 0
	resetEnemies:
		sll $t3, $t2, 2 # x4
		sw $zero, Active($t3) # store 0

		addi $t1, $t1, -1 # reverse order j ust because
		addi $t2, $t2, 6 # +6
		bne $t1, $zero, resetEnemies

	jal ClearBoard

	jal DrawMap
	
	li $a0, 1000	#
	li $v0, 32	# pause for 1 second
		syscall		#

DrawObjects: 
	jal MovePlayer

# Wait and read buttons
Begin_standby:	
		move $s0, $zero
		li $t0, 0x00000005			# load 25 into the counter for a ~50 milisec standby
	
Standby:
	blez $t0, EndStandby
	li $a0, 10	#
	li $v0, 32	# pause for 10 milisec
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

	# main erctangle
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
	li $a0, 16
	li $a1, 16
	li $a3, 20
	jal DrawVerticalLine

	li $a0, 46
	jal DrawVerticalLine

	# middle low horizontals
	li $a0, 16
	li $a1, 16
	li $a3, 25
	jal DrawHorizontalLine

	li $a0, 37
	li $a3, 46
	jal DrawHorizontalLine

	# radar rectangle
	li $a0, 25
	li $a1, 25
	li $a3, 30
	jal DrawVerticalLine

	li $a0, 37
	jal DrawVerticalLine

	li $a0, 25
	li $a1, 30
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
		slti $t5, $a0, 17
		slti $t6, $t8, 17
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
		slti $t6, $t8, 17
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
		slti $t5, $a0, 47
		slti $t6, $t8, 47
		nor $t6, $t6, $zero
		and $t7, $t5, $t6
		and $v0, $t4, $t7
		bne $v0, $zero, wallColDone
		# horizontal
		slti $t2, $a1, 17
		slti $t3, $t9, 17
		nor $t3, $t3, $zero
		and $t4, $t2, $t3
		slti $t5, $a0, 47
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
