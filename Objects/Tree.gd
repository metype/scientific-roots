extends "res://Objects/InteractibleObject.gd"

export (String) var item_id = "axe"
export (bool) var disable = true
export (bool) var destroy = false

var disabled : bool

func _interact(_with : String, ref : Node2D):
	if(_with == "axe"):
		ref._give_item("planks")
		call_deferred("free")
	elif(_with=="" or _with==null):
		ref._show_message("tree_comment")
	else:
		ref._show_message("tree_unhelpful")
