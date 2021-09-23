extends Node

export(float) var gravity = 50
export(float) var terminal_velocity = 300
export(bool) var should_randomize = true

onready var RandGen = RandomNumberGenerator.new()

func _ready():
	if(should_randomize):
		RandGen.randomize()
