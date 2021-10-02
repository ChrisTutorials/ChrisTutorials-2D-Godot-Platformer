extends Enemy

enum STATE { WALK, RUN, HIT }

export(float) var walk_speed = 75
export(float) var run_speed = 150

var current_state = STATE.WALK

func _physics_process(delta):
	waypoint_move(delta)
	
func _get_move_velocity(delta, direction):
	# Move towards waypoint
	var direction_x_sign = sign(direction.x)
	
	var move_speed : float
	
	match(current_state):
		STATE.WALK:
			move_speed = walk_speed
		STATE.RUN:
			move_speed = run_speed
	
	return Vector2(
		move_speed * direction_x_sign,
		min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
	)
	
func _get_distance_to_waypoint(waypoint_position : Vector2):
	return Vector2(self.position.x, 0).distance_to(Vector2(waypoint_position.x, 0))
			
func _on_AngryDetectionZone_body_shape_entered(body_id, body, body_shape, local_shape):
	animation_tree.set("parameters/player_detected/blend_position", 1)
	
	if(current_state == STATE.WALK):
		current_state = STATE.RUN

func _on_AngryDetectionZone_body_shape_exited(body_id, body, body_shape, local_shape):
	animation_tree.set("parameters/player_detected/blend_position", 0)
	
	if(current_state == STATE.RUN):
		current_state = STATE.WALK

# Angry Pig's Version of Get Hit
func get_hit(damage : float):
	self.health -= damage
	
	can_be_hit = false
	current_state = STATE.HIT
	
	var anim_selection = GameSettings.RandGen.randi_range(0, 1)
	
	animation_tree.set("parameters/hit/active", true)
	animation_tree.set("parameters/hit_variation/blend_amount", anim_selection)

# Run on animation player end of Hit1/Hit2	
func _hit_animation_finished():
	can_be_hit = true
	current_state = STATE.RUN

