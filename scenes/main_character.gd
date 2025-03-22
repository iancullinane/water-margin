@tool
extends Node2D

var CELL_SIZE = 16

@export var stats:Entity


@onready var sprite = $AnimatedSprite2D
@onready var name_label = $NameLabel

func _ready():
	if not Engine.is_editor_hint():
		name_label.text = stats.name
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
	print(direction)
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
