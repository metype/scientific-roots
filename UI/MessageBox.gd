extends TextureRect
class_name MessageBox

export (PoolIntArray) var skippable
export (PoolStringArray) var messages
export (PoolStringArray) var names

signal end
signal input_tried

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
	
func cancel():
	active = false
	
func parse_message():
	var parsing_regex : RegEx = RegEx.new()
	parsing_regex.compile("\"[^\"]+\"|[^\\s]+")
	var testing_regex : RegEx = RegEx.new()
	testing_regex.compile("^\\[.*\\]$")
	if(testing_regex.search(messages[message_pointer])):
		var results = []
		for result in parsing_regex.search_all(messages[message_pointer]):
			results.push_back(result.get_string())


func _process(delta):
	if not active:
		return
	if(messages[message_pointer].length() > progression_in_text):
		progression_in_text += progression_speed
	if(skippable[message_pointer] > 0 && Input.get_action_strength("interact") > 0 && not held_interact && messages[message_pointer].length() > progression_in_text):
		held_interact = true
		progression_in_text = messages[message_pointer].length()
		
	char_name.text = names[message_pointer]
	text.text = messages[message_pointer].substr(0,progression_in_text)
	
	if messages[message_pointer].begins_with("[image]"):
		text.text = ""
		screen_blot.visible = true
		image_view.texture = texture_to_display
	else:
		screen_blot.visible = false
		
	if messages[message_pointer].begins_with("[end]"):
		emit_signal("end")
		
	if messages[message_pointer].begins_with("[input]"):
		input_field.visible = true
		text.text = ""
		for i in range(0,10):
			if(Input.is_key_pressed(i+48) and input_text.length()  <= 6 and not invalidKeys.has(i)):
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
			emit_signal("input_tried", input_text, messages[message_pointer].substr(7,messages[message_pointer].length()-7))
	else:
		input_field.visible = false
		input_text = ""
		
	
	if(messages[message_pointer].length() <= progression_in_text or messages[message_pointer].begins_with("[image]") or messages[message_pointer].begins_with("[input]")):
		move_on.visible = true
		if(Input.get_action_strength("interact") > 0 && not held_interact):
			held_interact = true
			message_pointer += 1
			progression_in_text = 0
			if(messages.size()  <= message_pointer):
				active = false
				return
			if messages[message_pointer].begins_with("[image]"):
				texture_to_display = load("res://Media/UI/"+messages[message_pointer].substr(7,messages[message_pointer].length()-7)+".png")
	else:
		move_on.visible = false
	if(Input.get_action_strength("interact") <= 0):
			held_interact = false
	
	
