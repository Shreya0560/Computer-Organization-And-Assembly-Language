
.include "display_2211_0822.asm"
.include "math.asm"

# Player constants
.eqv PLAYER_X_START 0x1D00 # 30.0
.eqv PLAYER_Y_START 0x3200 # 50.0
.eqv PLAYER_X_MIN   0x0200 # 2.0
.eqv PLAYER_X_MAX   0x3900 # 57.0
.eqv PLAYER_Y_MIN   0x2E00 # 46.0
.eqv PLAYER_Y_MAX   0x3900 # 57.0
.eqv PLAYER_W       0x0500 # 5.0
.eqv PLAYER_H       0x0500 # 5.0
.eqv PLAYER_VEL     0x0100 # 1.0

# Bullet constants
.eqv BULLET_COLOR   COLOR_WHITE
.eqv MAX_BULLETS    10 # size of the bullet arrays
.eqv BULLET_DELAY   25 # frames
.eqv BULLET_VEL     0x0180 # 1.5

# Rock constants
.eqv ROCKS_TO_DESTROY 10
.eqv MAX_ROCKS        10
.eqv ROCK_VEL         0x0080 # 0.5 pixels/frame
.eqv ROCK_W           0x0500 # 5.00
.eqv ROCK_H           0x0500 # 5.00
.eqv ROCK_MAX_X       0x4000 # 64.0
.eqv ROCK_MAX_Y       0x4000 # 64.0
.eqv ROCK_DELAY       45 # frames
.eqv ROCK_MIN_ANGLE   115
.eqv ROCK_ANGLE_RANGE 110

.data

# Player variables
player_x:         .word PLAYER_X_START
player_y:         .word PLAYER_Y_START
player_next_shot: .word 0
player_lives:     .word 3
rocks_left:       .word ROCKS_TO_DESTROY

# Bullet variables
bullet_x:         .word 0:MAX_BULLETS
bullet_y:         .word 0:MAX_BULLETS
bullet_active:    .byte 0:MAX_BULLETS

# Rock variables
rock_x:           .word 0:MAX_ROCKS
rock_y:           .word 0:MAX_ROCKS
rock_vx:          .word 0:MAX_ROCKS
rock_vy:          .word 0:MAX_ROCKS
rock_active:      .byte 0:MAX_ROCKS
rock_next_spawn:  .word 0

# Sprites
player_sprite: .byte
-1 -1  4 -1 -1
-1  4  7  4 -1
 4  7  7  7  4
 4  4  4  4  4
 4 -1  2 -1  4

rock_sprite: .byte
-1 11 11 11 -1
11 11 11 11 11
11 11 11 11 11
11 11 11 11 11
-1 -1 11 11 11

.text

# -------------------------------------------------------------------------------------------------

.globl main
main:
	jal wait_for_start

	_loop:
		# TODO: uncomment these and implement them
		jal check_input
		jal update_all
		jal draw_all
		jal display_update_and_clear
		jal wait_for_next_frame
	jal check_game_over
	beq v0, 0, _loop
syscall_exit

# -------------------------------------------------------------------------------------------------

check_input: 
enter  
	jal input_get_keys_held
  	
  	and t0, v0, KEY_R 
  	beq t0, zero, _endif1
      	lw t1, player_x 
      	add t1, t1, PLAYER_VEL
      	mini t1, t1, PLAYER_X_MAX 
      	sw t1, player_x   	
 _endif1: 
  
  	and t0, v0, KEY_L
  	beq t0, zero, _endif2
      	lw t1, player_x 
      	sub t1, t1, PLAYER_VEL
      	maxi t1, t1, PLAYER_X_MIN
      	sw t1, player_x 
_endif2:  

	and t0, v0, KEY_U
  	beq t0, zero, _endif3
      	lw t1, player_y 
      	sub t1, t1, PLAYER_VEL
      	maxi t1, t1, PLAYER_Y_MIN
      	sw t1, player_y 
_endif3:  

	and t0, v0, KEY_D
  	beq t0, zero, _endif4
      	lw t1, player_y 
      	add t1, t1, PLAYER_VEL
      	mini t1, t1, PLAYER_Y_MAX
      	sw t1, player_y 
_endif4: 	

	and t0, v0, KEY_Z
 	beq t0,zero,_endif5
	jal fire_bullet
 	_endif5:  
 	
leave 

find_free_bullet:  
enter 
	li t0, 0 
	_loop: 
	lb t1, bullet_active(t0) #loads the value from address stored in t0 of bullets_active array
	bne t1, 0, _else
		move v0,t0 #return that index in bullet_active once we find a free bullet to use
	j _endif 
		
	_else: 
		li v0, -1  
		add t0, t0, 1
		blt t0, MAX_BULLETS, _loop	
	_endif: 
leave	

fire_bullet:  
enter
lw t0, frame_counter 
lw t1, player_next_shot 
blt t0,t1, _endif #checking if enough time passed between bullet shots
	add t1,t0,BULLET_DELAY  
	sw t1,player_next_shot 
	jal find_free_bullet #return v0, the address in array of a free bullet
	#lb t3,bullet_active(v0) 
	blt v0, 0, _endif #if no free bullets to fire, end  
		#print_str "pow-this works"
		li t2, 1
		sb t2, bullet_active(v0) #stores 1 into the address of v0 in the array bullets_active
		mul t2, v0, 4 # t2 is the index * 4 
		lw t0, player_x 
		add t0,t0,0x200 
  		sw t0, bullet_x(t2)#stores the x value of that bullet into the bullet_x array
  		lw t1, player_y
		sub t1,t1,0x100 
  		sw t1, bullet_y(t2)
_endif:		
leave 

wait_for_start:
enter
	_loop:
		jal draw_all
		jal display_update_and_clear
		jal wait_for_next_frame
	jal input_get_keys_pressed
	beq v0, 0, _loop
_return:
leave

# -------------------------------------------------------------------------------------------------

check_game_over:
enter
	li  v0, 1
	lw  t0, player_lives
	beq t0, 0, _return
	lw  t0, rocks_left
	beq t0, 0, _return
	li  v0, 0
_return:
leave

# -------------------------------------------------------------------------------------------------

draw_all:
enter
	# TODO: uncomment and implement these
	#jal draw_rocks
	jal draw_bullets
	jal draw_player
	jal draw_hud
leave

# -------------------------------------------------------------------------------------------------
draw_player: 
enter 
	lw a0, player_x 
	sra a0, a0, 8 
	lw a1, player_y
	sra a1, a1, 8 
	la a2, player_sprite
	jal display_blit_5x5_trans
leave 

draw_bullets: 
enter s0 
	li s0, 0  
	_loop: 
		lb t1,bullet_active(s0) 
		ble t1,0,_endif  
			mul t0, s0,4
			lw t2,bullet_x(t0) #loads the x value of the bullet
			sra a0, t2, 8 
			lw t3,bullet_y(t0)  
			sra a1, t3, 8	 
			li a3, BULLET_COLOR
			jal display_set_pixel	 
	_endif:	 
	add s0,s0,1 
	blt s0,MAX_BULLETS,_loop
leave s0

draw_hud:
enter
	# hide our shame :^)
	li a0, 0
	li a1, 0
	li a2, 64
	li a3, 7
	li v1, COLOR_DARK_GREY
	jal display_fill_rect

	# display rocks left
	li a0, 1
	li a1, 1
	lw a2, rocks_left
	jal display_draw_int

	# display lives left
	li a0, 45
	li a1, 1
	la a2, player_sprite
	jal display_blit_5x5_trans

	li a0, 51
	li a1, 1
	li a2, '='
	jal display_draw_char

	li a0, 57
	li a1, 1
	lw a2, player_lives
	jal display_draw_int
leave 
update_all: 
enter 
	#jal spawn_rocks
	#jal move_bullets
leave 

