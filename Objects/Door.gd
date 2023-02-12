extends StaticBody2D

export (Vector2) var open_pos
export (int) var speed
export (Texture) var door_texture

onready var texture_rect : TextureRect = $TextureRect

var opening = false

var default_pos

func _ready():
	default_pos = position
	if(door_texture != null):
		texture_rect.texture = door_texture
	

func _process(_delta):
	if(opening):
		position += ((default_pos + open_pos) - self.position).normalized()
	else:
		position += (default_pos - self.position).normalized()
		
func open():
	opening = true
	
func close():
	opening = false
