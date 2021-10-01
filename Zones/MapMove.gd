extends Area2D

export(PackedScene) var destination_scene

func _on_MapMove_body_shape_entered(body_id, body, body_shape, local_shape):
	get_tree().change_scene_to(destination_scene)
