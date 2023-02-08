extends Node2D

export (NodePath) var start_position

onready var start_object : Node2D = get_node(start_position)

signal level_change
signal loaded

func change_level(new : String):
	emit_signal("level_change", new)
	
func connected():
	emit_signal("loaded", start_object.global_position)
	
func input_success(id : String):
	pass
