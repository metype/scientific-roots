extends TextureRect

signal item_selected

var LastPressedTime = 0

var pos

func _process(delta):
	if (LastPressedTime > 0):
		LastPressedTime = max(0, LastPressedTime - delta)
		if (LastPressedTime == 0):
			OnSingleClick(get_local_mouse_position())

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
