extends StaticBody2D

export (Vector2) var open_pos
export (int) var speed

var opening = false

var default_pos

func _ready():
	default_pos = position
	

func _process(_delta):
	if(opening):
		position += ((default_pos + open_pos) - self.position).normalized()
	else:
		position += (default_pos - self.position).normalized()
		
func open():
	opening = true
	
func close():
	opening = false
