extends "res://Levels/Level.gd"

onready var door = $Door
onready var readable = $ReadableDoor
	
func input_success(id : String):
	door.open()
	if(readable != null):
		readable.call_deferred("free")
	pass #unlock door
	
