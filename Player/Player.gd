extends KinematicBody2D
class_name Player

export (int) var movement_speed = 24
export (int) var movement_delay = 70
export (float) var fade_speed = 1.5

onready var InteractToolTip = $InteractTooltip
onready var player_sprite = $AnimatedSprite
onready var equipped_label = $ColorRect/Label
onready var equipped_rect = $ColorRect
onready var fade_rect : ColorRect = $ColorRect2

var fade_amount = 0

var fading_in = false
var fading_out = false

var last_moved = 0
var facing_v : int
var facing_h : int
var interacted = false

var interactObject : Node2D = null

signal fade_black
signal fade_done

var item_name_data : Dictionary 
var item_index_data : Dictionary 

var inventory : Array = []

var inv_button_held = false
var selected_item : String

var movement_flags : int = 0b0000000

func init(item_name_data : Dictionary, item_index_data : Dictionary):
	self.item_name_data = item_name_data
	self.item_index_data = item_index_data

func _process(delta):
	fade_rect.color.a = fade_amount
	if  (interactObject != null):
		InteractToolTip.visible = true
	else:
		InteractToolTip.visible = false
		
	if(fading_in):
		fade_amount += delta * fade_speed
		if(fade_amount >= 1):
			emit_signal("fade_black")
			fading_in = false
			fading_out = true
	if(fading_out):
		fade_amount -= delta * fade_speed
		if(fade_amount <= 0):
			fading_in = false
			fading_out = false
			clear_move_flag(Definitions.InCutscene)
			emit_signal("fade_done")
			
func start_fade():
	fading_in = true
	fading_out = false
	set_move_flag(Definitions.InCutscene)
	
	
func move_in_direction(dir : Vector2, speed : int):
	if(OS.get_system_time_msecs() - last_moved <= movement_delay):
		return
	
	facing_v = dir.x
	facing_h = dir.y
	
	move_and_slide(dir * speed)
		
	last_moved = OS.get_system_time_msecs()
	pass
	
func set_move_flag(flag : int):
	movement_flags |= flag
	
func clear_move_flag(flag : int):
	movement_flags &= ~flag
	
func move_flag_set(flag : int):
	return (movement_flags & flag > 0)

func _physics_process(delta):
	if(selected_item != "" and selected_item != null):
		equipped_label.text = "Equipped " + item_name_data[selected_item]
		equipped_label.visible = true
		equipped_rect.visible = true
	else:
		equipped_label.visible = false
		equipped_rect.visible = false
	equipped_rect.rect_size = equipped_label.rect_size + Vector2(10,10)
	if(move_flag_set(Definitions.InCutscene | Definitions.MessageBox)):
		return
	if(Input.get_action_strength("inventory") > 0 and not inv_button_held):
		inv_button_held = true
		if(move_flag_set(Definitions.Inventory)):
			get_node("../Inventory").active = false
			clear_move_flag(Definitions.Inventory)
		else:
			var items : PoolStringArray
			for i in range(inventory.size()):
				items.append(inventory[i])
			get_node("../Inventory").current_items = items
			get_node("../Inventory").show()
			set_move_flag(Definitions.Inventory)
			_deequip()
	elif(Input.get_action_strength("inventory") == 0):
		inv_button_held = false
	
	if(move_flag_set(Definitions.Inventory)):
		return
	if(Input.get_action_strength("up") > 0) :
		player_sprite.play("walking_forward")
		move_in_direction(Vector2(0, -1), movement_speed)
	elif(Input.get_action_strength("down") > 0) :
		player_sprite.play("walking_back")
		move_in_direction(Vector2(0, 1), movement_speed)
	elif(Input.get_action_strength("left") > 0) :
		player_sprite.play("walking_left")
		move_in_direction(Vector2(-1, 0), movement_speed)
	elif(Input.get_action_strength("right") > 0) :
		player_sprite.play("walking_right")
		move_in_direction(Vector2(1, 0), movement_speed)
	else:
		if facing_h == 1:
			player_sprite.play("standing_back")
		if facing_h == -1:
			player_sprite.play("standing_forward")
		if facing_v == 1:
			player_sprite.play("standing_right")
		if facing_v == -1:
			player_sprite.play("standing_left")
	
	if(Input.get_action_strength("interact") > 0 and not interacted) :
		interacted = true
		if interactObject != null and interactObject.has_method("_interact"):
			interactObject._interact(selected_item, self)
	elif Input.get_action_strength("interact") <= 0:
		interacted = false

func _object_close(body):
	if body.has_method("_interact"):
		if !body.disabled:
			interactObject = body
	pass # Replace with function body.

func _clear_interacts():
	interactObject = null

func _object_left(body):
	if body.has_method("_interact"):
		interactObject = null
		
func _show_message(path : String, format_dict = {}):
	get_node("../MessageBoxHandler").display_message(path, format_dict)
			  
func _give_item(id : String):
	_show_message("recieve_item", {"item": item_name_data[id]})
	inventory.append(id)
	
func _remove_item(id : String):
	inventory.erase(id)
	
func _deequip():
	selected_item = ""
	
func select_item(id):
	if(inventory.size() > id):
		selected_item = inventory[id]
	_show_message("equip_item", {"item": item_name_data[selected_item]})
	clear_move_flag(Definitions.Inventory)
