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
		##li v0, 1
		#move a0,t0 
		#syscall
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
	jal draw_rocks
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

draw_rocks: 
enter s0 
	li s0, 0  
	_loop: 
		lb t1,rock_active(s0) 
		ble t1,0,_endif  
			mul t0, s0,4
			lw t2,rock_x(t0) #loads the x value of the bullet
			sra a0, t2, 8 
			lw t3,rock_y(t0)  
			sra a1, t3, 8	 
			la a2, rock_sprite
			jal display_blit_5x5_trans	 
			print_str"draw rocks" 
	_endif:	 
	add s0,s0,1 
	blt s0,MAX_BULLETS,_loop 
	#print_str"bye"
leave s0

update_all: 
enter 
	jal spawn_rocks
	jal move_bullets 
	jal move_rocks  
	jal collide_bullets_with_rocks 
	jal collide_rocks_with_player
leave  

move_bullets:
enter 
	li t0, 0 
	_loop: 
		lb t1,bullet_active(t0) 
		beq t1,0,_endif  
			print_str"move bullets1" 
			mul t3,t0,4
			lw t2,bullet_y(t3)  
			sub t2,t2,BULLET_VEL  
			sw t2,bullet_y(t3)
			bge t2,0,_endif 
				sb zero,bullet_active(t0) 
				print_str "move bullets2"
		_endif: 
		add t0,t0,1 
		blt t0,MAX_BULLETS,_loop
		
leave 

find_free_rock:  
enter 
	li t0, 0 
	_loop: 
	lb t1, rock_active(t0) #loads the value from address stored in t0 of bullets_active array
	bne t1, 0, _else
		move v0,t0 #return that index in bullet_active once we find a free bullet to use
	j _endif 
		
	_else: 
		li v0, -1  
		add t0, t0, 1
		blt t0, MAX_ROCKS, _loop	
	_endif: 
leave   

spawn_rocks:  
enter s0
lw t0, frame_counter
lw t1, rock_next_spawn
blt t0,t1, _endif #checking if enough time passed between bullet shots
	add t1,t0,ROCK_DELAY   
	sw t1,rock_next_spawn
	jal find_free_rock #return v0, the address in array of a free bullet
	move s0,v0
	beq s0, -1, _endif #if no free bullets to fire, end  
		print_str"spawn"
		li t2, 1
		sb t2, rock_active(s0) #stores 1 into the address of v0 in the array bullets_active
		li t2,0 
		mul t3, s0, 4 # t2 is the index * 4 
  		sw t2, rock_y(t3)#stores the x value of that bullet into the rock_y array
  		li a0,ROCK_MAX_X
  		jal random  
  		#move v0,a0 #Getting return value from random function,storing it into v0
  		move t2,v0 
  		mul t3, s0, 4 ## Need to load in t3 again bc of ATV rule
  		sw t2, rock_x(t3) 
  		li a0,ROCK_ANGLE_RANGE  
  		jal random 
  		move t2,v0 
  		add t2,t2,ROCK_MIN_ANGLE
  		move a1,t2 #To use mutliple arguments for a function, do we do it like this?
  		li a0,ROCK_VEL 
  		jal to_cartesian   
  		mul t3,s0,4
  		sw v0,rock_vx(t3) 
  		sw v1,rock_vy(t3)
  		#print_str "spawn2"
  		
  		
_endif:		
leave s0	

move_rocks:
enter 
	li t0, 0 
	_loop: 
		lb t1,rock_active(t0) 
		beq t1,0,_endif
			mul t5,t0,4
			lw t2,rock_vx(t5) 
			lw t3,rock_x(t5)
			add t3,t3,t2  
			and t3,t3,0x3FFF
			sw t3,rock_x(t5) 
			print_str"move rocks"
			lw t2,rock_vy(t5) 
			lw t3,rock_y(t5)
			add t3,t3,t2  
			sw t3,rock_y(t5) 
			lw t3,rock_y(t5)
			blt t3,ROCK_MAX_Y,_endif
				sb zero,rock_active(t0) 
				print_str"yes"
		_endif: 
		add t0,t0,1 
		blt t0,MAX_ROCKS,_loop
		
leave  

collide_bullets_with_rocks: 
enter s0,s1 
li s0, 0
_loop1: 
	li s1,0 
		_loop2:   
			move a0,s0 
			move a1,s1 
			jal rock_collides_with_bullet  
			#move s0,a0 
			#move s1,a1
			bne v0,1,_endif #if not qual to 1, no collision has happened so end
				li t2,0 
				sb t2,rock_active(s0) 
				sb t2,bullet_active(s1) 
				lw t3,rocks_left 
				sub t3,t3,1
				sw t3,rocks_left  
				_break: #breaking out of inner for loop  
				add s1,s1,1
				blt s1,MAX_BULLETS,_loop2
		_endif:  
		add s0,s0,1 
		blt s0,MAX_ROCKS,_loop1
		
		
leave s0,s1 

rock_collides_with_bullet: 
enter 
	li v0,0  
	lb t1,rock_active(a1) 
	beq t1,0,_return #if bullet is inactive, return 0
	lb t1,rock_active(a0) 
	beq t1,0,_return 
	mul t2,a1,4  
	mul t3,a0,4
	lw t1,bullet_x(t2) 
	lw t0,bullet_y(t2) 
	lw t4,rock_x(t3)
	lw t5,rock_y(t3) 
	blt t1,t4,_return 
	add t4,t4,ROCK_W 
	bgt t1,t4,_return 
	blt t0,t5,_return 
	add t5,t5,ROCK_H 
	bgt t0,t5,_return 
	li v0,1 # if we make it through all the conditions, return 1
	
_return:	
		
leave 


collide_rocks_with_player:
enter s0 
li s0,0  
_loop:
move a0,s0 
jal rock_collides_with_player 
bne,v0,1,_endif
jal kill_player

j _break

_endif:  
add s0,s0,1 
blt s0,MAX_ROCKS,_loop  
 
_break:
leave s0

kill_player:  
enter
	lw t1,player_lives
	sub,t1,t1,1 
	sw t1,player_lives	 
	li t1,PLAYER_X_START 
	sw t1,player_x 
	li t2,PLAYER_Y_START 
	sw t2,player_y 
	
	li t0,0 
	_loop1:  
		lb t1,bullet_active(t0) 
		li t2,0
		sb t2,bullet_active(t0) 
	_endif1: 
	add t0,t0,1 
	blt t0,MAX_BULLETS,_loop1
	
	li t0,0 
	_loop2:  
		lb t1,rock_active(t0) 
		li t2,0
		sb t2,rock_active(t0) 
	_endif2: 
	add t0,t0,1 
	blt t0,MAX_ROCKS,_loop2
leave 

rock_collides_with_player: 
enter 
li v0,0
lb t1,rock_active(a0) 
beq t1,0,_return #if rock is inactive, return  
mul t2,a0,4  
lw t0,rock_x(t2) 
lw t1,rock_y(t2)  
lw t3,player_x
lw t4,player_y 
sub t0,t0,t3 
sub t1,t1,t4
abs t0,t0 
abs t1,t1 
bgt t0,PLAYER_W,_return 
bgt t1,PLAYER_H,_return 
li v0,1
_return:
leave
