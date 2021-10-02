extends "res://Characters/Character.gd"

class_name Enemy

export(float) var waypoint_arrived_distance = 10
export(bool) var faces_right = true

export(Array, NodePath) var waypoints
export(int) var starting_waypoint = 0

var waypoint_position 
onready var waypoint_index = starting_waypoint setget set_waypoint_index
var velocity : Vector2 = Vector2.ZERO

export(bool) var can_be_hit = true
export(float) var collision_damage = 1

onready var animated_sprite = $AnimatedSprite
onready var animation_tree = $AnimationTree

func _ready():
	if(waypoints.size() > 0):
		waypoint_position = get_node(waypoints[starting_waypoint]).position

func waypoint_move(delta):
	if(waypoints.size() > 0):
		var direction = self.position.direction_to(waypoint_position)
		var distance = _get_distance_to_waypoint(waypoint_position)
		
		if(distance >= waypoint_arrived_distance):
			velocity = _get_move_velocity(delta, direction)
			
			var direction_x_sign = sign(direction.x)
			
			# Flip the direction
			if(direction_x_sign == -1):
				animated_sprite.flip_h = faces_right
			elif(direction_x_sign == 1):
				animated_sprite.flip_h = !faces_right
			
			velocity = move_and_slide(velocity, Vector2.UP)
		else:
			# Switch waypoints
			var num_waypoints = waypoints.size()
			
			# Loop through each waypoint until getting back to the starting waypoint
			if(waypoint_index < num_waypoints-1):
				self.waypoint_index += 1
			else:
				self.waypoint_index = 0
	
func _get_distance_to_waypoint(waypoint_position):
	return self.position.distance_to(waypoint_position)
			
func _get_move_velocity(_delta, _direction):
	printerr("Get Move Velocity has not been implemented")

func _on_EnemyCollisionHitbox_body_shape_entered(body_id, body, body_shape, local_shape):
	body.get_hit(collision_damage)

# SETTERS
func set_waypoint_index(value):
	waypoint_index = value
	waypoint_position = get_node(waypoints[value]).position
