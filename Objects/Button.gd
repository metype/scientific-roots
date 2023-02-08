extends "res://Objects/InteractibleObject.gd"
	
export (bool) var stay_down = true
	
var disabled = false

signal pressed

func _interact(with : String, ref : Node2D):
	if(disabled):
		return
	emit_signal("pressed")
	disabled = stay_down
			
