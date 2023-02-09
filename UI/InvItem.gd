extends TextureRect

signal item_selected

export (String) var tooltip

var LastPressedTime = 0

var pos

var mouse_inside = false

onready var tooltip_rect = $Node2D/ColorRect
onready var label = $Node2D/ColorRect/Label

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")

func _process(delta):
	if (LastPressedTime > 0):
		LastPressedTime = max(0, LastPressedTime - delta)
		if (LastPressedTime == 0):
			OnSingleClick(get_local_mouse_position())
	if(mouse_inside and texture != null):
		tooltip_rect.rect_global_position = get_global_mouse_position() + Vector2(2,2)
		label.text = tooltip
		tooltip_rect.visible = true
		tooltip_rect.rect_size = label.rect_size + Vector2(6,3)
		if(not get_global_rect().has_point(get_global_mouse_position())):
			mouse_inside = false
	else:
		tooltip_rect.visible = false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if(get_global_rect().has_point(get_global_mouse_position())):
			if not (event.button_index == BUTTON_WHEEL_UP || event.button_index == BUTTON_WHEEL_DOWN):
				if (LastPressedTime > 0):
					OnDoubleClick(get_local_mouse_position())
					LastPressedTime = 0
				else:
					LastPressedTime = 0.4

func OnDoubleClick(position):
	emit_signal("item_selected")

func OnSingleClick(position):
	pass
	
func _on_mouse_entered():
	mouse_inside = true
	
func _on_mouse_exited():
	mouse_inside = false
