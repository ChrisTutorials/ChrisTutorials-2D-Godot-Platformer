extends "res://Characters/Character.gd"

class_name Enemy

export(bool) var can_be_hit = true
export(float) var collision_damage = 1

func _on_EnemyCollisionHitbox_body_shape_entered(body_id, body, body_shape, local_shape):
	body.get_hit(collision_damage)
