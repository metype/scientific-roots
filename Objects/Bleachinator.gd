extends "res://Objects/InteractibleObject.gd"

export (String) var key = "test"
export (bool) var disable = true
export (bool) var destroy = false

var needed = ["chem_a","chem_b","chem_c","chem_d"]
var name_dict = {
	"chem_a" : "Chemical A",
	"chem_b" : "Chemical B",
	"chem_c" : "Chemical C",
	"chem_d" : "Chemical D"
}

var disabled = false

func _interact(_with : String, ref : Node2D):
	if(disabled):
		return
	if(_with == "" || _with == null):
		ref._show_message(key+"_comment")
		return
	elif(not needed.has(_with)):
		ref._show_message(key+"_failure")
		return
	needed.erase(_with)
	var comment_text = ""
	if(needed.size() > 0):
		comment_text = "Added. Required Chemicals Left :\n"
	else:
		comment_text = "Added. Bleachinating."
		if(destroy):
			call_deferred("free")
		disabled = disable
	
	for i in range(needed.size()):
		comment_text += name_dict[needed[i]] + " "
	ref._show_message(key+"_success",{"comment" : comment_text})
	ref._remove_item(_with)
	ref._deequip()
	
	if(needed.size() == 0):
		ref._give_item("bleach")
