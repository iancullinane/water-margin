@tool
extends Entity

var CELL_SIZE = GameConstants.CELL_SIZE

func _ready():
	super._ready()
		# Ensure DetectTouch and DetectKeyboard are initialized
	if DetectTouch and DetectKeyboard:
		DetectTouch.moved.connect(_on_swipe)
		DetectKeyboard.moved.connect(_on_move)




func _on_move(direction):
	if direction == "up":
		sprite.animation = "up_idle"
		position.y -= CELL_SIZE
	elif direction == "down":
		sprite.animation = "down_idle"
		position.y += CELL_SIZE
	elif direction == "right":
		sprite.animation = "right_idle"
		position.x += CELL_SIZE
	elif direction == "left":
		sprite.animation = "left_idle"
		position.x -= CELL_SIZE


	
func _on_swipe(direction):
	# Move by modifying the position
	if direction == "up":
		sprite.animation = "up_idle"
		position.y -= CELL_SIZE
	elif direction == "down":
		sprite.animation = "down_idle"
		position.y += CELL_SIZE
	elif direction == "right":
		sprite.animation = "right_idle"
		position.x += CELL_SIZE
	elif direction == "left":
		sprite.animation = "left_idle"
		position.x -= CELL_SIZE
