extends Node
class_name CutsceneHandler

export (NodePath) var cameraNodePath
export (NodePath) var playerNodePath

onready var camera : Camera2D = get_node(cameraNodePath)
onready var player : Player = get_node(playerNodePath)

var cutscenes : Dictionary
var cutscene_queue : Array = []
var cutscene_active : bool = false
var current_cutscene : Array = []
var cutscene_pointer : int = 0
var active_cutscene_key : String = ""

var start_time : int = 0
var start_camera_pos : Vector2
var end_camera_pos : Vector2
var interp_position : float = 0
var path_length : float = 0
var ends_after : float = 0
var requires_message_box : bool = false

func _ready():
	var file = File.new()
	file.open("res://Cutscenes/cutscenes.json", File.READ)
	var result = JSON.parse(file.get_as_text())
	file.close()
	if result.get_error() != OK:
		return
	cutscenes = result.get_result()

func _enqueue_cutscene(path : String):
	cutscene_queue.append(path)
	
func load_cutscene_data():
	current_cutscene = cutscenes[active_cutscene_key]
	cutscene_pointer = 0
	load_current_element()
	
func load_current_element():
	path_length = 0
	interp_position = 0
	ends_after = float(current_cutscene[cutscene_pointer]["ends_after"])
	start_camera_pos = parse_out_vector("start_camera_pos")
	end_camera_pos = parse_out_vector("end_camera_pos")
	requires_message_box = current_cutscene[cutscene_pointer].has("shown_message")
	if(requires_message_box):
		get_node("../MessageBoxHandler").display_message(current_cutscene[cutscene_pointer]["shown_message"])


func parse_out_vector(key : String):
	var data : String = ""
	if(not current_cutscene[cutscene_pointer].has(key)):
		return camera.global_position
	data = current_cutscene[cutscene_pointer][key]
	if(data == "player"):
		return player.global_position
	else:
		var sides = data.split(",")
		var ret_vector : Vector2 = Vector2(0,0)
		
		if(sides[0] == "player"):
			ret_vector.x = player.global_position.x
		else:
			ret_vector.x = float(sides[0])
			
		if(sides[1] == "player"):
			ret_vector.y = player.global_position.y
		else:
			ret_vector.y = float(sides[1])
			
		return ret_vector
		
func _message_box_closed():
	cutscene_pointer += 1
	if(cutscene_pointer >= current_cutscene.size()):
		cutscene_active = false
		return
	load_current_element()
	
func _process(delta):
	if(cutscene_active):
		player.set_move_flag(Definitions.InCutscene)
	else:
		if(cutscene_queue.size() > 0):
			cutscene_active = true
			active_cutscene_key = cutscene_queue.pop_front()
			load_cutscene_data()
		else:
			player.clear_move_flag(Definitions.InCutscene)
			return
	
	if(path_length <= ends_after):
		path_length += delta * 1000.0
	interp_position = path_length / ends_after
	
	camera.global_position = start_camera_pos.linear_interpolate(end_camera_pos, interp_position)
	
	if(path_length >= ends_after and not requires_message_box):
		cutscene_pointer += 1
		if(cutscene_pointer >= current_cutscene.size()):
			cutscene_active = false
			return
		load_current_element()
