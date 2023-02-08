extends Node2D

export(Array, Texture) var images
export(PoolIntArray) var current_items
export (NodePath) var camera

onready var cameraPos : Node2D = get_node(camera)

signal item_selected

var active = false
 
func show():
	active = true
	for i in range(9):
		if(i >= 9):
			break
		if(i >= current_items.size()):
			get_node("Item" + str(i+1)).texture = null
		else:
			get_node("Item" + str(i+1)).texture = images[current_items[i]]
		
func _process(_delta):
	if(not active):
		visible = false
	else:
		visible = true
	global_position = cameraPos.global_position

func _on_Item1_item_selected():
	if(not active):
		return
	active = false
	emit_signal("item_selected", 0)

func _on_Item2_item_selected():
	if(not active):
		return
	active = false
	emit_signal("item_selected", 1)

func _on_Item3_item_selected():
	if(not active):
		return
	active = false
	emit_signal("item_selected", 2)

func _on_Item4_item_selected():
	if(not active):
		return
	active = false
	emit_signal("item_selected", 3)

func _on_Item5_item_selected():
	if(not active):
		return
	active = false
	emit_signal("item_selected", 4)

func _on_Item6_item_selected():
	if(not active):
		return
	active = false
	emit_signal("item_selected", 5)

func _on_Item7_item_selected():
	if(not active):
		return
	active = false
	emit_signal("item_selected", 6)

func _on_Item8_item_selected():
	if(not active):
		return
	active = false
	emit_signal("item_selected", 7)

func _on_Item9_item_selected():
	if(not active):
		return
	active = false
	emit_signal("item_selected", 8)
