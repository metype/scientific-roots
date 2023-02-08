extends "res://Objects/InteractibleObject.gd"

export (String) var text_path = "missing"
export (bool) var one_shot = false

var disabled : bool

func _interact(_with : String, ref : Node2D):
	if(!self.disabled):
		ref._show_message(text_path)
		if(one_shot):
			self.disabled = true
			ref._clear_interacts()
