extends Entity

# var CELL_SIZE = GameConstants.CELL_SIZE

# func _ready():
# 	super._ready()
# 		# Ensure DetectTouch and DetectKeyboard are initialized
# 	if DetectTouch and DetectKeyboard:
# 		DetectTouch.moved.connect(_on_swipe)
# 		DetectKeyboard.zoomed.connect(_on_zoom)
# 		DetectKeyboard.moved.connect(_on_move)


# func zoom_in():
# 	if $Camera2D:
# 		$Camera2D.zoom = $Camera2D.zoom * 1.1

# func zoom_out():
# 	if $Camera2D:
# 		$Camera2D.zoom = $Camera2D.zoom * 0.9

# func _on_move(direction):
# 	if direction == "up":
# 		sprite.animation = "up_idle"
# 		position.y -= CELL_SIZE
# 	elif direction == "down":
# 		sprite.animation = "down_idle"
# 		position.y += CELL_SIZE
# 	elif direction == "right":
# 		sprite.animation = "right_idle"
# 		position.x += CELL_SIZE
# 	elif direction == "left":
# 		sprite.animation = "left_idle"
# 		position.x -= CELL_SIZE

# func _on_zoom(direction):
# 	if direction == "in":
# 		zoom_in()
# 	elif direction == "out":
# 		zoom_out()

	
# func _on_swipe(direction):
# 	# Move by modifying the position
# 	if direction == "up":
# 		sprite.animation = "up_idle"
# 		position.y -= CELL_SIZE
# 	elif direction == "down":
# 		sprite.animation = "down_idle"
# 		position.y += CELL_SIZE
# 	elif direction == "right":
# 		sprite.animation = "right_idle"
# 		position.x += CELL_SIZE
# 	elif direction == "left":
# 		sprite.animation = "left_idle"
# 		position.x -= CELL_SIZE
