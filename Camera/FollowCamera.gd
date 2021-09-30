extends Camera2D

onready var top_left = $Bounds/TopLeft
onready var bottom_right = $Bounds/BottomRight

func _ready():
	self.limit_top = top_left.global_position.y
	self.limit_left = top_left.global_position.x
	self.limit_right = bottom_right.global_position.x
	self.limit_bottom = bottom_right.global_position.y
