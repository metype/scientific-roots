extends Control

var held = false

func _ready():
	if(Input.get_action_strength("interact") > 0):
		held = true

func _process(_delta):
	if(Input.get_action_strength("interact") > 0 and not held):
		get_tree().quit()
	elif(Input.get_action_strength("interact") == 0):
		held = false
