extends "res://Characters/Character.gd"

export(float) var move_speed = 200
export(float) var jump_impulse = 600
export(float) var enemy_bounce_impulse = 400
export(float) var knockback_collision_speed = 50
export(int) var max_jumps = 2
export(float) var jump_damage = 1

enum STATE { IDLE, RUN, JUMP, DOUBLE_JUMP, HIT}

onready var animated_sprite = $AnimatedSprite
onready var animation_tree = $AnimationTree
onready var jump_hitbox = $JumpHitbox
onready var invincible_timer = $InvincibleTimer

signal changed_state(new_state_string, new_state_id)

var velocity : Vector2

var current_state = STATE.IDLE setget set_current_state
var jumps = 0

func _physics_process(delta):
	var input = get_player_input()
	
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	set_anim_parameters()
	
	match(current_state):
		STATE.IDLE, STATE.RUN, STATE.JUMP, STATE.DOUBLE_JUMP:
			velocity = normal_move(input)
			pick_next_state()
		STATE.HIT:
			velocity = hit_move()
	
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
	
func adjust_flip_direction(input : Vector2):
	if(sign(input.x) == 1):
		animated_sprite.flip_h = false
	elif(sign(input.x) == -1):
		animated_sprite.flip_h = true
	
func set_anim_parameters():
	animation_tree.set("parameters/x_sign/blend_position", sign(velocity.x))
	animation_tree.set("parameters/y_sign/blend_amount", sign(velocity.y))
	
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
	else:
		if(Input.is_action_just_pressed("jump") && jumps < max_jumps):
			self.current_state = STATE.DOUBLE_JUMP
			

# Uses Input to determine which directions the player is pressing down on for use in movement
func get_player_input():
	var input : Vector2
	
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	return input

func jump():
	velocity.y = -jump_impulse
	jumps += 1
	
func _on_JumpHitbox_area_shape_entered(area_id, area, area_shape, local_shape):
	var enemy = area.owner
	
	if(enemy is Enemy && enemy.can_be_hit):
		if(jump_hitbox.global_position.y > area.global_position.y):
			print("jump HB " + str(jump_hitbox.global_position))
			print("body Pos" + str(area.global_position))
			
			# Jump Attack
			velocity.y = -enemy_bounce_impulse
			
			enemy.get_hit(jump_damage)
	
	
	pass # Replace with function body.

func get_hit(damage : float):
	if(invincible_timer.is_stopped()):
		self.health -= damage
		self.current_state = STATE.HIT
		invincible_timer.start()
	
func on_hit_finished():
	self.current_state = STATE.IDLE
	
# SETTERS
func set_current_state(new_state):
	match(new_state):
		STATE.JUMP:
			jump()
		STATE.DOUBLE_JUMP:
			jump()
			animation_tree.set("parameters/double_jump/active", true)
		STATE.HIT:
			animation_tree.set("parameters/hit/active", true)
	
	current_state = new_state
	emit_signal("changed_state", STATE.keys()[new_state], new_state)


