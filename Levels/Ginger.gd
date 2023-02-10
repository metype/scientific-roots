extends "res://Objects/InteractibleObject.gd"

var disabled : bool

func _interact(_with : String, ref : Node2D):
	if(_with == null or _with == ""):
		ref._show_message("ginger_weird")
	elif(_with != "bleach"):
		ref._show_message("ginger_failed")
	if(_with == "bleach"):
		ref._show_message("ginger_broken_down")
		ref._remove_item("bleach")
		ref._deequip()
		call_deferred("free")
