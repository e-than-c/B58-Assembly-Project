##################################################################### 
# 
# CSCB58 Winter 2023 Assembly Final Project 
# University of Toronto, Scarborough 
# 
# Student: Ethan Chan, 1008153089, chanet14, eth.chan@mail.utoronto.ca 
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8 (update this as needed)  
# - Unit height in pixels: 8 (update this as needed) 
# - Display width in pixels: 256 (update this as needed) 
# - Display height in pixels: 256 (update this as needed) 
# - Base Address for Display: 0x10008000 ($gp) 
# 
# Which milestones have been reached in this submission? 
# (See the assignment handout for descriptions of the milestones) 
# - Milestone 1/2/3 (choose the one the applies) 
# 
# Which approved features have been implemented for milestone 3? 
# (See the assignment handout for the list of additional features) 
# 1. (fill in the feature, if any) 
# 2. (fill in the feature, if any) 
# 3. (fill in the feature, if any) 
# ... (add more if necessary) 
# 
# Link to video demonstration for final submission: 
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it! 
# 
# Are you OK with us sharing the video with people outside course staff? 
# - No
# 
# Any additional information that the TA needs to know: 
# - (write here, if any) 
# 
##################################################################### 
.eqv  BASE_ADDRESS  0x10008000 
.eqv PLAYER_COL 0x0000ff
#.eqv PLY_MAX_X  # max x value that a player can move
#.eqv PLY_MAX_Y	  # max y vaule that a player can move
  	# settings: unit width and height = 8, display width and height = 256
 .data
.text 
 	li $t0, BASE_ADDRESS # $t0 stores the base address for display 
 	li $t1, 0xff0000   # $t1 stores the red colour code 
 	li $t2, 0x00ff00   # $t2 stores the green colour code 
 	#li $t3, 0x0000ff   # $t3 stores the blue colour code 
  
 	#sw $t1, 0($t0)  # paint the first (top-left) unit red.  
 	#sw $t1, 12($t0)	# paint 3rd unit on first row red?
 	
 	# making a green character
 	#sw $t2, 64($t0)
 	#sw $t2, 256($t0)
 
 # draw main platform
    	li $t9, 0       # loop counter
 	li $t3, 8       # unit width and height
    	li $t5, 2560   # y-coordinate of line
    	add $t6, $t0, $t5  # memory address of first pixel on line
    	addi $t6, $t6, 48 #adjust for x coord shift, do # of pixels * 8
# loop to draw a line
draw_main_plat:
    sw $t1, 0($t6) # Set the pixel at the current memory address to red
    addi $t6, $t6, 4 # Move to the next pixel in the same row
    addi $t9, $t9, 1 # Increment the loop counter
    beq $t9, 8, draw_ply_start # Exit loop when the line is complete
    j draw_main_plat
    
draw_ply_start:
	li $t2, PLAYER_COL # get blue colour
	subi $t6, $t6, 128 # y coord of char (each line is 128)
	sub $t6, $t6, 16 # x coord (each pixel is 9)
	sw $t2, 0($t6) 	# Draw the dot at the pixel
	addi $sp, $sp, -4 # make space on the stack
	sw $t6, 0($sp) # push the address of where the character starts onto the stack
 	j main
HandleKeypressW: # w was pressed
	lw $a0, 0($sp) # pop player address off the stack
	addi $sp, $sp, 4 # reclaim the space
	li $t1, PLAYER_COL # get player colour
	# draw a pixel on row above
	subi $a0, $a0, 128 # one pixel above
	sw $t1, 0($a0) # draw the actual pixel
	j wait_key

HandleKeypressA:
	#sw $v0, action
	addi $t3, $t3, 2
	j wait_key
HandleKeypressS:
	#sw $v0, action
	addi $t3, $t3, 3
	j wait_key

HandleKeypressD:
 	#sw $t2, 260($t0)
 	#sw $t2, 264($t0)
 	addi $t3, $t3, 4
 	j wait_key

# put functions in here, before using main
.globl main
main:

idle: 
 	#j END
 	# draw out character position
 	lw $t0, 0($sp) # pop the player address into $t0
	addi $sp, $sp, 4 # reclaim space 
	li $t1, 0x0000ff 
	sw $t1, 0($t0) #draw character
wait_key:	
 	li $t9, 0xffff0000 # access the memory location of the key input
 	lw $t8, 0($t9) #load it into another register
 	beq $t8, 1, HandleKeypress # if a key was pressed, the value will be 1
 	#j wait_key # go back to waiting for a keypress to happen
 	j wait_key
 	
HandleKeypress:
 	lw $t2, 4($t9) # assuming $t9 set to 0xffff0000
 	addi $sp, $sp, -4 # make space on stack
 	sw $t0, 0($sp) # push player's current address onto the stack
 	beq $t2, 0x77, HandleKeypressW # ASCII for 'w'
 	beq $t2, 0x61, HandleKeypressA # ASCII for 'a'
 	beq $t2, 0x73, HandleKeypressS # ASCII for 's'
 	beq $t2, 0x64, HandleKeypressD # ASCII for 'd'
 	beq $t2, 0x1b, QUIT # ASCII for 'ESC', to quit game
 	j wait_key # go back to waiting for a keypress

 QUIT:
 	# program continues to run until quit
 	j END
 	
 
 	
 	# to invoke sleep, load 32 into v0 and number of milleseconds into a0
	# li $v0, 32 
	# li $a0, 1000   # Wait one second (1000 milliseconds) 
 
END:
 	li $v0, 10 # terminate the program gracefully 
 	syscall 
