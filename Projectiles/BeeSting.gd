extends KinematicBody2D

export(float) var damage = 1
export(float) var move_speed = 100

var target_direction = Vector2.ZERO

func _physics_process(delta):
	var collision = move_and_collide(move_speed * target_direction * delta)
	
	if(is_instance_valid(collision)):
		queue_free()


func _on_AttackArea_body_shape_entered(body_id, body, body_shape, local_shape):
	body.get_hit(damage)
	queue_free()
