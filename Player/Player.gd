extends KinematicBody2D
class_name Player

export (int) var movement_speed = 24
export (int) var movement_delay = 70
export (float) var fade_speed = 1.5

onready var InteractToolTip = $InteractTooltip
onready var player_sprite : AnimatedSprite = $AnimatedSprite
onready var equipped_label : Label = $ColorRect/Label
onready var equipped_rect : ColorRect = $ColorRect
onready var fade_rect : ColorRect = $ColorRect2

var fade_amount : float = 0

var fading_in : bool = false
var fading_out : bool = false

var last_moved : float = 0
var facing_dir : Vector2 = Vector2(0,0)
var pre_facing_dir : Vector2 = Vector2(0,0)
var interacted : bool = false

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
			emit_signal("fade_done")
			clear_move_flag(Definitions.InFade)
			
func start_fade():
	fading_in = true
	fading_out = false
	set_move_flag(Definitions.InFade)
	
	
func move_in_direction(dir : Vector2, speed : int, change_facing : bool = true):
	if(OS.get_system_time_msecs() - last_moved <= movement_delay):
		return
	
	if(change_facing):
		facing_dir = dir
	
	move_and_slide(dir * speed)
		
	last_moved = OS.get_system_time_msecs()
	pass
	
func set_move_flag(flag : int):
	movement_flags |= flag
	
func clear_move_flag(flag : int):
	movement_flags &= ~flag
	
func move_flag_set(flag : int):
	return (movement_flags & flag > 0)
	
func go_to_stand():
	if pre_facing_dir.y > 0:
		player_sprite.play("standing_back")
	if pre_facing_dir.y < 0:
		player_sprite.play("standing_forward")
	if pre_facing_dir.x > 0:
		player_sprite.play("standing_right")
	if pre_facing_dir.x < 0:
		player_sprite.play("standing_left")
		
func keep_moving():
	if(facing_dir.length() > 0):
		pre_facing_dir = facing_dir
	if (facing_dir.y < 0):
		player_sprite.play("walking_forward")
	elif (facing_dir.y > 0):
		player_sprite.play("walking_back")
	elif (facing_dir.x < 0):
		player_sprite.play("walking_left")
	elif (facing_dir.x > 0):
		player_sprite.play("walking_right")
	else:
		go_to_stand()
	move_in_direction(facing_dir, movement_speed, false)

func _physics_process(delta):
	if(selected_item != "" and selected_item != null):
		equipped_label.text = "Equipped " + item_name_data[selected_item]
		equipped_label.visible = true
		equipped_rect.visible = true
	else:
		equipped_label.visible = false
		equipped_rect.visible = false
	equipped_rect.rect_size = equipped_label.rect_size + Vector2(10,10)
	if(move_flag_set(Definitions.InFade)):
		keep_moving()
		return
	if(move_flag_set(Definitions.MessageBox | Definitions.InCutscene)):
		go_to_stand()
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
		go_to_stand()
		return
		
	var move_dir : Vector2 = Vector2(0,0)
	
	if(Input.get_action_strength("up") > 0) :
		move_dir += Vector2(0, -1)
	if(Input.get_action_strength("down") > 0) :
		move_dir += Vector2(0, 1)
	if(Input.get_action_strength("left") > 0) :
		move_dir += Vector2(-1, 0)
	if(Input.get_action_strength("right") > 0) :
		move_dir += Vector2(1, 0)
		
	facing_dir = move_dir.normalized()
	
	keep_moving()
	
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
	
func _play_cutscene(path : String):
	get_node("../CutsceneHandler")._enqueue_cutscene(path)
			  
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
