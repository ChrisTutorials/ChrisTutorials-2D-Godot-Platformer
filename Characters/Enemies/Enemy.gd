extends KinematicBody2D

class_name Enemy

export(float) var health = 3
export(bool) var can_be_hit = true

func _get_hit(damage : float):
	push_error("Get hit has not been implemented")
