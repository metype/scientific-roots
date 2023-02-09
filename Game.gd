extends Node2D

var attached = false

var answers : Dictionary = {"puzzle1_door" : "41118", "locker_room_door" : "247", "vinegar_door" : "38310", "clean_room_door" : "5061", "chem_room_door" : "55517"}

onready var player = $Player
onready var inventory = $Inventory

var next_level = ""

var action_queue : Array = []

var item_index_data : Dictionary = {
 "axe" : 0,
 "bleach" : 1,
 "planks" : 2,
 "sector_b_keycard" : 3,
 "cabinet_key" : 4,
 "rusty_key" : 5,
 "guard_key" : 6,
 "break_room_key" : 7,
 "coffee" : 8,
 "sector_a_keycard" : 9,
 "chem_a" : 10,
 "chem_b" : 11,
 "chem_c" : 12,
 "chem_d" : 13,
 "knife": 14,
 "hammer": 15,
 "corrosive": 16
}

var item_name_data : Dictionary = {
 "axe" : "Axe",
 "bleach" : "Bleach",
 "planks" : "Planks",
 "sector_b_keycard" : "Sector B Keycard",
 "cabinet_key" : "Golden Key",
 "rusty_key" : "Rusted Key",
 "guard_key" : "Sector B Lab Keycard",
 "break_room_key" : "Golden Key",
 "coffee" : "Hot Coffee",
 "sector_a_keycard" : "Sector A Keycard",
 "chem_a" : "Chemical A",
 "chem_b" : "Chemical B",
 "chem_c" : "Chemical C",
 "chem_d" : "Chemical D",
 "knife": "Knife",
 "hammer": "Hammer",
 "corrosive": "Corrosive"
}

func change_level(new_level : String):
	next_level = new_level
	player.start_fade()
	push_action("load_level")
	
func push_action(action : String):
	action_queue.append(action)
	
func _ready():
	next_level = "Tutorial"
	load_ready()
	player.init(item_name_data, item_index_data)
	inventory.init(item_name_data, item_index_data)

func set_player_pos(pos):
	player.position = pos
	
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


func load_ready():
	var level = ResourceLoader.load("res://Levels/" + next_level + ".tscn")
	var lvl = get_node("Level")
	remove_child(lvl)
	lvl.call_deferred("free")
	
	add_child_below_node(get_node("Dummy"), level.instance())
	attached = false
	
func commit_action():
	if(action_queue.size() > 0):
		var action = action_queue.pop_front()
		if(action == "load_level"):
			load_ready()


func _on_Player_fade_black():
	commit_action()
