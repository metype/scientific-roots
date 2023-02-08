extends "res://Objects/InteractibleObject.gd"

export (String) var preamble = ""
export (String) var item_id = "axe"
export (bool) var disable = true
export (bool) var destroy = false

var disabled = false

func _interact(_with : String, ref : Node2D):
	if(disabled):
		return
	if(preamble != ""):
		ref._show_message(preamble)
	ref._give_item(item_id)
	ref._deequip()
	if(destroy):
		call_deferred("free")
	disabled = disable
