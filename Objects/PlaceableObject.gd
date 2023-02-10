extends "res://Objects/InteractibleObject.gd"

export (String) var desired_object
export (Texture) var finished_decal
export (Rect2) var decal_rect
export (String) var key_name
export (bool) var remove_afterward = true
export (NodePath) var remove_object

onready var collider = $CollisionShape2D
onready var text_rect = $TextureRect

var disabled : bool

func _interact(_with : String, ref : Node2D):
	if(_with == null or _with == ""):
		ref._show_message(key_name+"_comment")
	elif(_with != desired_object):
		ref._show_message(key_name+"_failed")
	if(_with == desired_object):
		ref._show_message(key_name+"_success")
		text_rect.texture = finished_decal
		text_rect.rect_position = decal_rect.position
		text_rect.rect_size = decal_rect.size
		text_rect.visible = true
		ref._deequip()
		if(remove_afterward):
			ref._remove_item(desired_object)
		collider.disabled = true
		get_node(remove_object).call_deferred("free")
