extends Enemy

enum STATE { WALK, RUN, HIT }

export(float) var walk_speed = 75
export(float) var run_speed = 150
export(float) var waypoint_arrived_distance = 10
export(bool) var faces_right = true

export(Array, NodePath) var waypoints
export(int) var starting_waypoint = 0

var waypoint_position
var waypoint_index setget set_waypoint_index
var velocity = Vector2.ZERO
var current_state = STATE.WALK

onready var animated_sprite = $AnimatedSprite
onready var animation_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	self.waypoint_index = starting_waypoint

func _physics_process(delta):
	var direction = self.position.direction_to(waypoint_position)
	var distance_x = Vector2(self.position.x, 0).distance_to(Vector2(waypoint_position.x, 0))
	
	if(distance_x >= waypoint_arrived_distance):
		# Move towards waypoint
		var direction_x_sign = sign(direction.x)
		
		var move_speed : float
		
		match(current_state):
			STATE.WALK:
				move_speed = walk_speed
			STATE.RUN:
				move_speed = run_speed
		
		velocity = Vector2(
			move_speed * direction_x_sign,
			min(velocity.y + GameSettings.gravity, GameSettings.terminal_velocity)
		)
		
		# Flip the direction
		if(direction_x_sign == -1):
			animated_sprite.flip_h = faces_right
		elif(direction_x_sign == 1):
			animated_sprite.flip_h = !faces_right
		
		move_and_slide(velocity, Vector2.UP)
	else:
		# Switch waypoints
		var num_waypoints = waypoints.size()
		
		# Loop through each waypoint until getting back to the starting waypoint
		if(waypoint_index < num_waypoints-1):
			self.waypoint_index += 1
		else:
			self.waypoint_index = 0
			
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

# SETTERS
func set_waypoint_index(value):
	waypoint_index = value
	waypoint_position = get_node(waypoints[value]).position
