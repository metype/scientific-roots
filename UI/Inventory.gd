extends Node2D

export (Array, Texture) var images
export (PoolStringArray) var current_items
export (NodePath) var camera

onready var cameraPos : Node2D = get_node(camera)

signal item_selected

var active = false

var item_name_data : Dictionary 
var item_index_data : Dictionary 

func init(item_name_data : Dictionary, item_index_data : Dictionary):
	self.item_name_data = item_name_data
	self.item_index_data = item_index_data
 
func show():
	active = true
	for i in range(9):
		if(i >= 9):
			break
		if(i >= current_items.size()):
			get_node("Item" + str(i+1)).texture = null
		else:
			var item_id = current_items[i]
			var item_index_id = item_index_data[item_id]
			var desired_texture = images[item_index_id]
			get_node("Item" + str(i+1)).texture = desired_texture
			get_node("Item" + str(i+1)).tooltip = item_name_data[item_id]
		
func _process(_delta):
	if(not active):
		visible = false
	else:
		visible = true
	global_position = cameraPos.global_position

func _on_item_selected(index):
	if(not active):
		return
	active = false
	emit_signal("item_selected", index)
