extends Area2D


func _on_BottomOfScreen_body_shape_entered(body_id, body, body_shape, local_shape):
	body.die()
