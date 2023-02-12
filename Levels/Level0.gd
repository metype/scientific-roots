extends "res://Levels/Level.gd"

onready var door = $Door
onready var readable = $ReadableDoor
	
func input_success(id : String):
	door.open()
	if(readable != null):
		readable.call_deferred("free")
	pass #unlock door

func _on_cutscene_trigger_entered(body, path : String, trigger_name : String, oneshot : bool):
	if(body.has_method("_play_cutscene")):
		body._play_cutscene(path)
		if(oneshot):
			get_node(trigger_name).set_deferred("monitoring",false)
			
