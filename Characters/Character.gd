extends KinematicBody2D

signal health_changed(new_health)

export(float) var health = 3 setget set_health

func set_health(value):
	if(health != value):
		emit_signal("health_changed", value)
	
	health = value
	
	if(health <= 0):
		queue_free()

func _get_hit(damage : float):
	push_error("Get hit has not been implemented")
	
func _on_hit_finished():
	push_error("Get hit has not been implemented")

