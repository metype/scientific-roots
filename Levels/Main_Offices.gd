extends "res://Levels/Level.gd"

onready var door = $Door14
onready var door2 = $Door11
onready var door3 = $Door12
onready var door4 = $Door13
onready var readable = $Door14/ReadableDoor
onready var readable2 = $Door11/ReadableDoor
onready var readable3 = $Door12/ReadableDoor
onready var readable4 = $Door13/ReadableDoor

func _on_LevelEnd_body_entered(body : Node2D, new_level : String, facing_dir):
	if(body.has_method("_show_message")):
		change_level(new_level, facing_dir)
	
func input_success(id : String):
	if(id=="locker_room_door"):
		door.open()
		if(readable != null):
			readable.call_deferred("free")
	if(id=="vinegar_door"):
		door2.open()
		if(readable2 != null):
			readable2.call_deferred("free")
	if(id=="clean_room_door"):
		door3.open()
		if(readable3 != null):
			readable3.call_deferred("free")
	if(id=="chem_room_door"):
		door4.open()
		if(readable4 != null):
			readable4.call_deferred("free")
	pass #unlock door
	
