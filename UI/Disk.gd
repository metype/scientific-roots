extends Control

var held = false

func _ready():
	if(Input.get_action_strength("interact") > 0):
		held = true

func _process(_delta):
	if(Input.get_action_strength("interact") > 0 and not held):
		get_tree().change_scene("res://UI/Control2.tscn")
	elif(Input.get_action_strength("interact") == 0):
		held = false
