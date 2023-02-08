extends Node2D
export (NodePath) var camera
export (NodePath) var playerPath

onready var cameraPos : Node2D = get_node(camera)
onready var player : Node2D = get_node(playerPath)

onready var messageBox = $MessageBox

var messages : Dictionary

var messageQueue : Array = []

func _ready():
	var file = File.new()
	file.open("res://Messages/messages.json", File.READ)
	var result = JSON.parse(file.get_as_text())
	file.close()
	if result.get_error() != OK:
		return
	messages = result.get_result()

func _process(delta):
	global_position = cameraPos.global_position
	if(messageBox.active):
		player.set_move_state(false)
		messageBox.visible = true
	else:
		player.set_move_state(true)
		messageBox.visible = false
		if(messageQueue.size() >= 2):
			var message_path = messageQueue.pop_front()
			var format_dict = messageQueue.pop_front()
			var skippable : PoolIntArray
			var messages : PoolStringArray
			var names : PoolStringArray
			if(not self.messages.has(message_path)):
				message_path = "missing"
			var arr = self.messages[message_path]
			for i in range(0, arr.size()):
				skippable.append(int(arr[i]["skip"]))
				if(format_dict != null):
					messages.append(arr[i]["text"].format(format_dict))
				else:
					messages.append(arr[i]["text"])
				names.append(arr[i]["name"])
			messageBox.names = names
			messageBox.messages = messages
			messageBox.skippable = skippable
			messageBox.set_active()
		
	

func display_message(message_path : String, format_dict = null):
	messageQueue.append(message_path)
	messageQueue.append(format_dict)
