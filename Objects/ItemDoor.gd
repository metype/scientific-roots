extends "res://Objects/InteractibleObject.gd"

export (Vector2) var open_pos
export (int) var speed
export (String) var desired_object
export (String) var key_name
export (bool) var remove_item

var opening = false

var disabled = false

var default_pos

func _ready():
	default_pos = position

func _process(_delta):
	if(opening):
		position += ((default_pos + open_pos) - self.position).normalized()
	else:
		position += (default_pos - self.position).normalized()
		
func open():
	opening = true
	
func close():
	opening = false

func _interact(_with : String, ref : Node2D):
	if(_with == null or _with == ""):
		ref._show_message(key_name+"_comment")
	elif(_with != desired_object):
		ref._show_message(key_name+"_failure")
	if(_with == desired_object):
		disabled = true
		ref._clear_interacts()
		ref._show_message(key_name+"_success")
		open()
		if(remove_item):
			ref._remove_item(_with)
		ref._deequip()
