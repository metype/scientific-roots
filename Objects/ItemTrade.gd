extends "res://Objects/InteractibleObject.gd"

export (String) var used_item_id = "axe"
export (String) var new_item_id = "axe"
export (String) var key = "test"
export (bool) var disable = true
export (bool) var destroy = false

var disabled = false

func _interact(_with : String, ref : Node2D):
	if(disabled):
		return
	if(_with == "" || _with == null):
		ref._show_message(key+"_comment")
		return
	elif(_with != used_item_id):
		ref._show_message(key+"_failure")
		return
	ref._show_message(key+"_success")
	ref._remove_item(used_item_id)
	ref._give_item(new_item_id)
	ref._deequip()
	if(destroy):
		call_deferred("free")
	disabled = disable
