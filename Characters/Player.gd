extends KinematicBody2D

export(float) var move_speed = 200
export(float) var jump_impulse = 600

enum STATE { IDLE, RUN, JUMP }

onready var animated_sprite = $AnimatedSprite
onready var animation_tree = $AnimationTree


var velocity : Vector2

var current_state = STATE.IDLE setget set_current_state
var jumps = 0

func _physics_process(delta):
	var input = get_player_input()
	adjust_flip_direction(input)
	
	velocity = Vector2(
		input.x * move_speed,
		min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
	)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	set_anim_parameters()
	
	pick_next_state()
	
func adjust_flip_direction(input : Vector2):
	if(sign(input.x) == 1):
		animated_sprite.flip_h = false
	elif(sign(input.x) == -1):
		animated_sprite.flip_h = true
	
func set_anim_parameters():
	animation_tree.set("parameters/x_move/blend_position", sign(velocity.x))
	
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
		# TODO Double Jump
		pass
			

# Uses Input to determine which directions the player is pressing down on for use in movement
func get_player_input():
	var input : Vector2
	
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	return input

func jump():
	velocity.y = -jump_impulse
	jumps += 1

# SETTERS
func set_current_state(new_state):
	match(new_state):
		STATE.JUMP:
			jump()
	
	current_state = new_state
