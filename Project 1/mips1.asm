find_free_bullet:  

	li t0, 0 
	_loop: 
	#acess bullets active at index i  
	#la t1, bullets_active 
	#add t1, t1, t0 
	#lb t2,(t1) 
	lb t1, bullets_active(t0) #loads the value from address stored in t0 of bullets_active array
	bne t1, 0, else_ 
		move v0,t1 #return bullets_active at that index once we find a free bullet to use
	j _endif 
		
	_else: 
		li v0, -1 
	_endif: 
	add t0, t0, 1
	blt t0, MAX_BULLETS, _loop

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
