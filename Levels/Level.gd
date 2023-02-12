extends Node2D

export (NodePath) var start_position

onready var start_object : Node2D = get_node(start_position)

signal level_change
signal loaded

func change_level(new : String, facing_dir : Vector2):
	emit_signal("level_change", new, facing_dir)
	
func connected():
	emit_signal("loaded", start_object.global_position)
	
func input_success(id : String):
	pass

func _on_LevelEnd_body_entered(body : Node2D, new_level : String, facing_dir : Vector2):
	if(body.has_method("_show_message")):
		change_level(new_level, facing_dir)
