extends Control

export(int) var sprite_width = 18

onready var texture_rect = $TextureRect

func _ready():
	var active_player = GameManager.active_player
	active_player.connect("health_changed", self, "_on_health_changed")
	GameManager.connect("game_over", self, "_on_game_over")
	texture_rect.rect_size.x = sprite_width * active_player.health
	
func _on_health_changed(new_health):
	texture_rect.rect_size.x = sprite_width * new_health
	
	if(new_health <= 0):
		texture_rect.visible = false
	else:
		texture_rect.visible = true

func _on_game_over():
	texture_rect.visible = false
