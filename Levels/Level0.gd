extends "res://Levels/Level.gd"

onready var door = $Door
onready var readable = $ReadableDoor

func _on_LevelEnd_body_entered(body : Node2D, new_level : String):
	if(body.has_method("_show_message")):
		change_level(new_level)
	
func input_success(id : String):
	door.open()
	if(readable != null):
		readable.call_deferred("free")
	pass #unlock door
	
