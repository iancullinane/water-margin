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


func _ready():
	print("Entity ready:", name, stats)
	if stats and stats.animation_resource == null:
		stats.animation_resource = preload("res://assets/resources/kanji_anim.tres")
	if not Engine.is_editor_hint():
		if stats:
			name_label.text = stats.name
			if stats.animation_resource:
				sprite.sprite_frames = stats.animation_resource
	sprite.animation = "down_idle"  # Or whatever your default animation is
	sprite.play()

# Repeat configuration for held movement
var repeat_initial_delay: float = 0.20
var repeat_interval: float = 0.12

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
				_step_dir(dir)
				_next_emit_at[dir] += repeat_interval

func _step_dir(dir: String) -> void:
	if dir == "up":
		sprite.animation = "up_idle"
		position.y -= CELL_SIZE
	elif dir == "down":
		sprite.animation = "down_idle"
		position.y += CELL_SIZE
	elif dir == "left":
		sprite.animation = "left_idle"
		position.x -= CELL_SIZE
	elif dir == "right":
		sprite.animation = "right_idle"
		position.x += CELL_SIZE
	if current_player:
		SignalBus.current_player_moved.emit(self)

func _on_press_dir(dir: String) -> void:
	_held[dir] = true
	_held_time[dir] = 0.0
	_step_dir(dir) # immediate first step
	_next_emit_at[dir] = repeat_initial_delay

func _on_release_dir(dir: String) -> void:
	_held[dir] = false
	_held_time[dir] = -1.0
	_next_emit_at[dir] = 0.0

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



# signal moved
# signal zoomed

# var last_move_time = 0
# var move_buffer = 0.2  # Minimum seconds between moves 

func _input(event):
	

		

	if event.is_action("zoom_in"):
		emit_signal("zoomed", "in")

	if event.is_action("zoom_out"):
		emit_signal("zoomed", "out")
