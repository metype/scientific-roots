extends TextureRect
class_name MessageBox

export (PoolIntArray) var skippable
export (PoolStringArray) var messages
export (PoolStringArray) var names

signal end
signal input_tried
signal cutscene_box_closed

onready var text = $Text
onready var input_text_area = $InputFieldBG/InputFieldText
onready var char_name = $CharacterName
onready var move_on = $MoveOnArrow
onready var image_view = $ScreenBlot/ImageView
onready var screen_blot = $ScreenBlot
onready var input_field = $InputFieldBG

var message_pointer : int = 0
var progression_in_text = 0
var progression_speed = 1
var active = false
var held_interact = true
var held_backspace = false

var input_text = ""
var texture_to_display : Texture

var invalidKeys = []

var parsed_message_data : Dictionary = {}

func set_active():
	active = true
	message_pointer = 0
	progression_in_text = 0
	parse_message()
	if parsed_message_data["type"] == "image":
				texture_to_display = load("res://Media/UI/"+parsed_message_data["image_path"]+".png")
	
func cancel():
	active = false
	
func parse_message():
	parsed_message_data = {}
	var parsing_regex : RegEx = RegEx.new()
	parsing_regex.compile("\\s+(?=((\\\\[\\\\\']|[^\\\\\'])*\'(\\\\[\\\\\']|[^\\\\\'])*\')*(\\\\[\\\\\']|[^\\\\\'])*$)") # Hell
	var testing_regex : RegEx = RegEx.new()
	testing_regex.compile("^\\[.*\\]$")
	var pre_end = 0
	var results = []
	var new_string = messages[message_pointer].substr(1,messages[message_pointer].length()-2)
	if(testing_regex.search(messages[message_pointer])):
		for result in parsing_regex.search_all(new_string):
			results.push_back(new_string.substr(pre_end, result.get_start() - pre_end))
			pre_end = result.get_end()
		results.push_back(new_string.substr(pre_end, new_string.length() - pre_end))
		for KVPair in results:
			var key : String = KVPair.split("=")[0]
			var value : String = KVPair.split("=")[1]
			value = value.strip_edges(true, true)
			value = value.substr(1, value.length() - 2)
			parsed_message_data[key] = value
			
	else:
		parsed_message_data["type"] = "text"
		parsed_message_data["message"] = messages[message_pointer]
		
	if(not parsed_message_data.has("message")):
		parsed_message_data["message"] = "No message defined."

func _process(delta):
	if not active:
		return
	if(messages[message_pointer].length() > progression_in_text):
		progression_in_text += progression_speed
	if(skippable[message_pointer] > 0 && Input.get_action_strength("interact") > 0 && not held_interact && messages[message_pointer].length() > progression_in_text):
		held_interact = true
		progression_in_text = messages[message_pointer].length()
	char_name.text = names[message_pointer]
	text.text = parsed_message_data["message"].substr(0,progression_in_text)
	
	if parsed_message_data["type"] == "image":
		screen_blot.visible = true
		image_view.texture = texture_to_display
	else:
		screen_blot.visible = false
		
	if parsed_message_data["type"] == "end":
		emit_signal("end")
		
	if parsed_message_data["type"] == "input":
		input_field.visible = true
		for i in range(0,10):
			if(Input.is_key_pressed(i+48) and input_text.length()  < int(parsed_message_data["input_length"]) and not invalidKeys.has(i)):
				invalidKeys.append(i)
				input_text+=str(i)
			elif(not Input.is_key_pressed(i+48)):
				invalidKeys.erase(i)
				
		input_text_area.text = input_text
				
		if(Input.is_physical_key_pressed(KEY_BACKSPACE) and input_text.length() > 0 and not held_backspace):
			input_text = input_text.substr(0, input_text.length() - 1)
			held_backspace = true
		elif(not Input.is_physical_key_pressed(KEY_BACKSPACE)):
			held_backspace = false
				
		if(Input.get_action_strength("interact") > 0 && not held_interact):
			emit_signal("input_tried", input_text, parsed_message_data["input_key"], parsed_message_data["input_id"])
	else:
		input_field.visible = false
		input_text = ""
		
	
	if(parsed_message_data["message"].length() <= progression_in_text):
		move_on.visible = true
		if(Input.get_action_strength("interact") > 0 && not held_interact):
			held_interact = true
			message_pointer += 1
			progression_in_text = 0
			if(messages.size()  <= message_pointer):
				if(skippable[message_pointer-1] == 2):
					emit_signal("cutscene_box_closed")
				active = false
				return
			parse_message()
			if parsed_message_data["type"] == "image":
				texture_to_display = load("res://Media/UI/"+parsed_message_data["image_path"]+".png")
	else:
		move_on.visible = false
	if(Input.get_action_strength("interact") <= 0):
			held_interact = false
	
	
