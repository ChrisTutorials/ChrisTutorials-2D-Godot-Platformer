extends "res://Characters/Character.gd"

export(float) var move_speed = 180
export(float) var jump_impulse = 500
export(float) var enemy_bounce_impulse = 400
export(float) var knockback_collision_speed = 50
export(float) var wall_slide_friction = 0.5
export(int) var max_jumps = 2
export(float) var jump_damage = 1

enum STATE { IDLE, RUN, JUMP, DOUBLE_JUMP, HIT, WALL_SLIDE}

onready var animated_sprite = $AnimatedSprite
onready var animation_tree = $AnimationTree
onready var jump_hitbox = $JumpHitbox
onready var invincible_timer = $InvincibleTimer
onready var wall_jump_timer = $WallJumpTimer

signal changed_state(new_state_string, new_state_id)
signal player_died(player)

var velocity : Vector2

var current_state = STATE.IDLE setget set_current_state
var jumps = 0
var wall_jump_direction : Vector2
var is_bordering_wall : bool

func _physics_process(delta):
	var input = get_player_input()
	
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	is_bordering_wall = get_is_on_wall_raycast_test()
	set_anim_parameters()
	
	match(current_state):
		STATE.IDLE, STATE.RUN, STATE.JUMP, STATE.DOUBLE_JUMP:
			if(wall_jump_timer.is_stopped()):
				velocity = normal_move(input)
			else:
				velocity = wall_jumping_movement()
				
			pick_next_state()
		STATE.HIT:
			velocity = hit_move()
		STATE.WALL_SLIDE:
			velocity = wall_slide_move()
			pick_next_state()
	
func normal_move(input):
	adjust_flip_direction(input)
	
	return Vector2(
		input.x * move_speed,
		min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
	)

# Knockback where player has no control over movement temporarily
func hit_move():
	var knockback_direction : Vector2
	
	# Facing Left
	if(animated_sprite.flip_h):
		knockback_direction = Vector2.RIGHT
	else:
		knockback_direction = Vector2.LEFT
		
	knockback_direction = knockback_direction.normalized()
		
	return knockback_collision_speed * knockback_direction
	
func wall_slide_move():
	return Vector2(
		velocity.x,
		min(velocity.y + (GameSettings.gravity * wall_slide_friction), GameSettings.terminal_velocity)
	)
	
func wall_jumping_movement():
	return Vector2(
		move_speed * wall_jump_direction.x,
		min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
	)
	
func adjust_flip_direction(input : Vector2):
	if(sign(input.x) == 1):
		animated_sprite.flip_h = false
	elif(sign(input.x) == -1):
		animated_sprite.flip_h = true
	
func set_anim_parameters():
	animation_tree.set("parameters/x_sign/blend_position", sign(velocity.x))
	animation_tree.set("parameters/y_sign/blend_amount", sign(velocity.y))
	
	var is_on_wall_int : int
	
	if(is_bordering_wall):
		is_on_wall_int = 1
	else:
		is_on_wall_int = 0
		
	animation_tree.set("parameters/is_on_wall/blend_amount", is_on_wall_int)
	
func pick_next_state():
	if(is_on_floor()):
		jumps = 0
		
		# If jump is pressed while the character is on the ground, then jump
		if(Input.is_action_just_pressed("jump")):
			self.current_state = STATE.JUMP
		elif(abs(velocity.x) > 0):
			self.current_state = STATE.RUN
		else:
			self.current_state = STATE.IDLE
	elif(Input.is_action_just_pressed("jump") && jumps < max_jumps):
		if(is_bordering_wall):
			self.current_state = STATE.JUMP
		else:
			self.current_state = STATE.DOUBLE_JUMP
	elif(is_bordering_wall):
		self.current_state = STATE.WALL_SLIDE
	elif(self.current_state == STATE.WALL_SLIDE && !is_bordering_wall):
		self.current_state = STATE.JUMP

# Uses Input to determine which directions the player is pressing down on for use in movement
func get_player_input():
	var input : Vector2
	
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	return input

# Returns the direction that the character is currently facing based on the
# flip direction of the animated sprite
func get_facing_direction():
	if(animated_sprite.flip_h == false):
		return Vector2.RIGHT
	else:
		return Vector2.LEFT

# Checks the currently facing direction for any walls right in front of the character
# Returns true if it finds a wall and false otherwise
func get_is_on_wall_raycast_test():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, global_position + 10 * get_facing_direction(), [self], self.collision_mask)
	
	if(result.size() > 0):
		return true
	else:
		return false

func jump():
	velocity.y = -jump_impulse
	jumps += 1
	
func wall_jump():
	velocity.y = -jump_impulse
	jumps = 1
	wall_jump_direction = -get_facing_direction()
	wall_jump_timer.start()
	
func _on_JumpHitbox_area_shape_entered(area_id, area, area_shape, local_shape):
	var enemy = area.owner
	
	if(enemy is Enemy && enemy.can_be_hit):
		# Check to see if we are hitting the enemy at the right position and velocity
		if(jump_hitbox.global_position.y >= area.global_position.y - 1 && velocity.y > 0):
			# Jump Attack
			velocity.y = -enemy_bounce_impulse
			
			enemy.get_hit(jump_damage)
	
	
	pass # Replace with function body.

func get_hit(damage : float):
	if(invincible_timer.is_stopped()):
		# Tell the world that player suffered lethal damage
		if(damage >= self.health):
			emit_signal("player_died", self)
		
		self.health -= damage
		self.current_state = STATE.HIT
		invincible_timer.start()
	
func on_hit_finished():
	self.current_state = STATE.IDLE
	
func _on_Player_tree_entered():
	GameManager.active_player = self
	
	
# SETTERS
func set_current_state(new_state):
	match(new_state):
		STATE.JUMP:
			if(current_state == STATE.WALL_SLIDE):
				# There are multiple ways to enter jump state, only
				# run the jump function when it is actually pressed down
				if(Input.is_action_just_pressed("jump")):
					wall_jump()
			else:
				jump()
		STATE.DOUBLE_JUMP:
			jump()
			animation_tree.set("parameters/double_jump/active", true)
		STATE.HIT:
			animation_tree.set("parameters/hit/active", true)
		STATE.WALL_SLIDE:
			jumps = 0
	
	current_state = new_state
	emit_signal("changed_state", STATE.keys()[new_state], new_state)

