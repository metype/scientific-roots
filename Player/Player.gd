extends KinematicBody2D

export (int)var movement_speed = 24
export (int)var movement_delay = 70

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

var can_move = true

var interactObject : Node2D = null

signal load_ready

var invData : Dictionary = {
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

var nameData : Dictionary = {
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

var inventory : Array = []

var inv_button_held = false
var inventory_open = false
var selected_item : String

func _process(delta):
	fade_rect.color.a = fade_amount
	if  (interactObject != null):
		InteractToolTip.visible = true
	else:
		InteractToolTip.visible = false
		
	if(fading_in):
		fade_amount += 0.02
		if(fade_amount >= 1):
			emit_signal("load_ready")
			fading_in = false
			fading_out = true
	if(fading_out):
		fade_amount -= 0.02
		if(fade_amount <= 0):
			fading_in = false
			fading_out = false
			can_move = true
			
func level_transition():
	fading_in = true
	fading_out = false
	can_move = false
	
	
func move_in_direction(dir : Vector2, speed : int):
	if(OS.get_system_time_msecs() - last_moved <= movement_delay):
		return
	
	facing_v = dir.x
	facing_h = dir.y
	
	move_and_slide(dir * speed)
		
	last_moved = OS.get_system_time_msecs()
	pass
	
func set_move_state(can : bool):
	can_move = can

func _physics_process(delta):
	if(selected_item != "" and selected_item != null):
		equipped_label.text = "Equipped " + nameData[selected_item]
		equipped_label.visible = true
		equipped_rect.visible = true
	else:
		equipped_label.visible = false
		equipped_rect.visible = false
	equipped_rect.rect_size = equipped_label.rect_size + Vector2(10,10)
	if(Input.get_action_strength("inventory") > 0 and not inv_button_held):
		inv_button_held = true
		if(inventory_open):
			get_node("../Inventory").active = false
			inventory_open = false
		else:
			var items : PoolIntArray
			for i in range(inventory.size()):
				items.append(invData[inventory[i]])
			get_node("../Inventory").current_items = items
			get_node("../Inventory").show()
			inventory_open = true
			_deequip()
	elif(Input.get_action_strength("inventory") == 0):
		inv_button_held = false
	
	if(!can_move || inventory_open):
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
	_show_message("recieve_item", {"item": nameData[id]})
	inventory.append(id)
	
func _remove_item(id : String):
	inventory.erase(id)
	
func _deequip():
	selected_item = ""
	
func select_item(id):
	if(inventory.size() > id):
		selected_item = inventory[id]
	_show_message("equip_item", {"item": nameData[selected_item]})
	inventory_open = false
