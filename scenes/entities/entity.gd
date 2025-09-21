extends Node2D
class_name Entity


@export var stats:EntityData

var CELL_SIZE = GameConstants.CELL_SIZE

@onready var sprite = $AnimatedSprite2D
@onready var name_label = $NameLabel

var current_player: bool = false:
	set(value):
		if current_player == value:
			return
		current_player = value
		if current_player:
			_connect_control_signals()
		else:
			_disconnect_control_signals()

func _ready():
	print("Entity ready:", name, stats)
	if stats and stats.animation_resource == null:
		stats.animation_resource = preload("res://assets/resources/kanji_anim.tres")
	if not Engine.is_editor_hint():
		if stats:
			name_label.text = stats.name
			if stats.animation_resource:
				sprite.sprite_frames = stats.animation_resource
		# Ensure DetectTouch and DetectKeyboard are initialized
	if not Engine.is_editor_hint() and current_player:
		_connect_control_signals()
	sprite.animation = "down_idle"  # Or whatever your default animation is
	sprite.play()

func _process(_delta):
	if Engine.is_editor_hint():
		if stats:
			name_label.text = stats.name
			if stats.animation_resource and sprite.sprite_frames != stats.animation_resource:
				sprite.sprite_frames = stats.animation_resource
				sprite.animation = "down_idle"
				sprite.play()

func _exit_tree():
	_disconnect_control_signals()

func set_controllable(value: bool) -> void:
	if current_player == value:
		return
	current_player = value
	if Engine.is_editor_hint():
		return
	if current_player:
		_connect_control_signals()
	else:
		_disconnect_control_signals()

func _connect_control_signals() -> void:
	if DetectTouch and not DetectTouch.moved.is_connected(_on_swipe):
		DetectTouch.moved.connect(_on_swipe)
	if DetectKeyboard:
		if not DetectKeyboard.zoomed.is_connected(_on_zoom):
			DetectKeyboard.zoomed.connect(_on_zoom)
		if not DetectKeyboard.moved.is_connected(_on_move):
			DetectKeyboard.moved.connect(_on_move)

func _disconnect_control_signals() -> void:
	if DetectTouch and DetectTouch.moved.is_connected(_on_swipe):
		DetectTouch.moved.disconnect(_on_swipe)
	if DetectKeyboard:
		if DetectKeyboard.zoomed.is_connected(_on_zoom):
			DetectKeyboard.zoomed.disconnect(_on_zoom)
		if DetectKeyboard.moved.is_connected(_on_move):
			DetectKeyboard.moved.disconnect(_on_move)

func zoom_in():
	var cam = get_node_or_null("Camera2D")
	if cam:
		cam.zoom = cam.zoom * 1.1

func zoom_out():
	var cam = get_node_or_null("Camera2D")
	if cam:
		cam.zoom = cam.zoom * 0.9

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
	
	# Emit signal if this is the current player
	if current_player:
		SignalBus.current_player_moved.emit(self)

func _on_zoom(direction):
	if direction == "in":
		zoom_in()
	elif direction == "out":
		zoom_out()

func _on_swipe(direction):
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
	
	# Emit signal if this is the current player
	if current_player:
		SignalBus.current_player_moved.emit(self)
