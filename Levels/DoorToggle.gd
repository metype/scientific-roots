extends "res://Objects/InteractibleObject.gd"

onready var door = $Door

var disabled

func _interact(_with : String, ref : Node2D):
	if(door.opening):
		door.close()
	else:
		door.open()
