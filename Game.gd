extends Node2D

var attached = false

var answers : Dictionary = {"puzzle1_door" : "41118", "locker_room_door" : "247", "vinegar_door" : "38310", "clean_room_door" : "5061", "chem_room_door" : "55517"}

onready var player = $Player

var next_level = ""

func change_level(new_level : String):
	next_level = new_level
	player.level_transition()
	
	
	
func _ready():
	next_level = "Tutorial"
	_on_Player_load_ready()

func set_player_pos(pos):
	get_node("Player").position = pos
	
func _process(_delta):
	if(get_node("Level") != null && !attached):
		attached = true	
		get_node("Level").connect("level_change", self, "change_level")
		get_node("Level").connect("loaded", self, "set_player_pos")
		get_node("Level").connected()


func _on_MessageBox_input_tried(input: String, id : String):
	if(answers[id] == input):
		get_node("Level").input_success(id)
		get_node("MessageBoxHandler").display_message(id+"_success")
	else:
		get_node("MessageBoxHandler").display_message(id+"_failure")


func _on_MessageBox_end():
	get_tree().change_scene("res://UI/Control.tscn")


func _on_Player_load_ready():
	var level = ResourceLoader.load("res://Levels/" + next_level + ".tscn")
	var lvl = get_node("Level")
	remove_child(lvl)
	lvl.call_deferred("free")
	
	add_child_below_node(get_node("Dummy"), level.instance())
	attached = false
