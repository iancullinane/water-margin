@tool
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

		if value == true:
			# Connect touch signals when becoming the current player
			if !DetectTouch.moved.is_connected(_on_swipe):
				DetectTouch.moved.connect(_on_swipe)
		else:
			# Disconnect touch signals when no longer the current player
			if DetectTouch.moved.is_connected(_on_swipe):
				DetectTouch.moved.disconnect(_on_swipe)

		current_player = value



func _ready():
	add_to_group("entities")
	if stats and stats.animation_resource == null:
		stats.animation_resource = preload("res://assets/animations/chick_anim.tres")
	if not Engine.is_editor_hint():
		if stats:
			name_label.text = stats.name
			if stats.animation_resource:
				sprite.sprite_frames = stats.animation_resource
	sprite.animation = "down_idle"  # Or whatever your default animation is
	sprite.play()

# Repeat configuration for held movement
var repeat_initial_delay: float = 0.20 # this is how long to wait before repeating a direction
var repeat_interval: float = 0.33 # this adjusts speed when holding down a direction

# Internal held-state tracking
var _held := {"up": false, "down": false, "left": false, "right": false}
var _held_time := {"up": -1.0, "down": -1.0, "left": -1.0, "right": -1.0}
var _next_emit_at := {"up": 0.0, "down": 0.0, "left": 0.0, "right": 0.0}

func _physics_process(delta: float) -> void:
	if !current_player:
		return

	# Manage press/release transitions
	if Input.is_action_just_pressed("world_up"):
		_on_press_dir("up")
	if Input.is_action_just_released("world_up"):
		_on_release_dir("up")

	if Input.is_action_just_pressed("world_down"):
		_on_press_dir("down")
	if Input.is_action_just_released("world_down"):
		_on_release_dir("down")

	if Input.is_action_just_pressed("world_left"):
		_on_press_dir("left")
	if Input.is_action_just_released("world_left"):
		_on_release_dir("left")

	if Input.is_action_just_pressed("world_right"):
		_on_press_dir("right")
	if Input.is_action_just_released("world_right"):
		_on_release_dir("right")

	# Repeat while held with controlled interval
	for dir in _held.keys():
		if _held[dir]:
			_held_time[dir] += delta
			if _held_time[dir] >= _next_emit_at[dir]:
				_move(dir)
				_next_emit_at[dir] += repeat_interval

func _move(dir: String) -> void:
	var target_pos := position

	if dir == "up":
		target_pos.y -= CELL_SIZE
	elif dir == "down":
		target_pos.y += CELL_SIZE
	elif dir == "left":
		target_pos.x -= CELL_SIZE
	elif dir == "right":
		target_pos.x += CELL_SIZE

	if not _can_move_to(target_pos):
		return

	if dir == "up":
		sprite.animation = "up_idle"
	elif dir == "down":
		sprite.animation = "down_idle"
	elif dir == "left":
		sprite.animation = "left_idle"
	elif dir == "right":
		sprite.animation = "right_idle"

	position = target_pos

	if current_player:
		SignalBus.current_player_moved.emit(self)

func _on_press_dir(dir: String) -> void:
	_held[dir] = true
	_held_time[dir] = 0.0
	_move(dir) # immediate first step
	_next_emit_at[dir] = repeat_initial_delay

func _on_release_dir(dir: String) -> void:
	_held[dir] = false
	_held_time[dir] = -1.0
	_next_emit_at[dir] = 0.0

func _can_move_to(target_pos: Vector2) -> bool:
	var game_map := _get_current_map()
	if game_map == null:
		return true

	var tile_coords := game_map.get_tile_from_global(target_pos)

	if _is_tile_blocked(game_map, tile_coords):
		return false

	if _is_entity_at_position(target_pos):
		return false

	return true

func _get_current_map() -> GameMap:
	var level_loader = get_tree().root.find_child("LevelLoader", true, false)
	if level_loader and level_loader.has_method("get_current_map"):
		return level_loader.get_current_map()
	return null

func _is_tile_blocked(game_map: GameMap, tile_coords: Vector2i) -> bool:
	var terrain_layer := game_map.get_terrain_layer()
	if terrain_layer == null:
		return false

	var tile_data := terrain_layer.get_cell_tile_data(tile_coords)
	if tile_data == null:
		return false

	var movement_value = tile_data.get_custom_data("movement")
	return movement_value == 1

func _is_entity_at_position(target_pos: Vector2) -> bool:
	var entities := get_tree().get_nodes_in_group("entities")
	for entity in entities:
		if entity != self and entity.position.distance_to(target_pos) < 1.0:
			return true
	return false

func _process(_delta):
	if Engine.is_editor_hint():
		if stats:
			name_label.text = stats.name
			if stats.animation_resource and sprite.sprite_frames != stats.animation_resource:
				sprite.sprite_frames = stats.animation_resource
				sprite.animation = "down_idle"
				sprite.play()

func set_controllable(value: bool) -> void:
	if current_player == value:
		return
	current_player = value

	# Connect touch controls when setting controllable
	if current_player and !DetectTouch.moved.is_connected(_on_swipe):
		DetectTouch.moved.connect(_on_swipe)

func zoom_in():
	var cam = get_node_or_null("Camera2D")
	if cam:
		cam.zoom = cam.zoom * 1.1

func zoom_out():
	var cam = get_node_or_null("Camera2D")
	if cam:
		cam.zoom = cam.zoom * 0.9

# Actual movement

func _on_move(direction):
	_move(direction)

func _on_swipe(direction):
	_move(direction)


func _on_zoom(direction):
	if direction == "in":
		zoom_in()
	elif direction == "out":
		zoom_out()


func _input(event):

	if event.is_action("zoom_in"):
		emit_signal("zoomed", "in")

	if event.is_action("zoom_out"):
		emit_signal("zoomed", "out")
