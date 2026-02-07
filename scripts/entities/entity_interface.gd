extends Node2D
class_name IEntity

func is_entity():
	return true


@export var stats:EntityData
@onready var name_label = $NameLabel
@onready var animation_player = $AnimationPlayer
@onready var mover = $Mover

var CELL_SIZE = GameConstants.CELL_SIZE
const DIRECTIONS = ["up", "down", "left", "right"]

# Player movement variables
# ========================
var current_player: bool = false
var direction: Vector2
# var last_non_zero_direction: Vector2 = Vector2.DOWN  # Store last direction for persistence

# Repeat configuration for held movement
# Entities move only "square-by-square" so we keep track of this stuff
# and only initiate moves from square to square
# var repeat_initial_delay: float = 0.20 # this is how long to wait before repeating a direction
# var repeat_interval: float = 0.33 # this adjusts speed when holding down a direction

# # Internal held-state tracking
# var _move_state := {
# 	"up": {"held": false, "time": -1.0, "next_emit": 0.0},
# 	"down": {"held": false, "time": -1.0, "next_emit": 0.0},
# 	"left": {"held": false, "time": -1.0, "next_emit": 0.0},
# 	"right": {"held": false, "time": -1.0, "next_emit": 0.0}
# }

# Smooth movement variables
var target_position: Vector2 = Vector2.ZERO
# var is_moving: bool = false
# var move_speed: float = 150.0  # Pixels per second
# var facing_left: bool = false  # Track if character is facing left for sprite flipping

# ===========================================


func _ready() -> void:
	add_to_group("entities")
	print("Entity ready:", name, stats)
	# if the EntityCtl was not set in editor
	# it will expect the parent to be EntityCtl
	# animation_player.play("idle_down")
	target_position = position  # Initialize to current position

func _physics_process(_delta: float) -> void:
	_process_held_movement(_delta)
	# _process_smooth_movement(_delta)
	# set_animation()

	if current_player:
		get_input()

# func set_animation():

# 	# Store last non-zero direction when moving
# 	if direction.length() > 0:
# 		last_non_zero_direction = direction

# 	# Use last direction when not moving
# 	var anim_direction = direction if direction.length() > 0 else last_non_zero_direction

# 	# Set the blend position based on direction
# 	$AnimationTree.set("parameters/MoveStateMachine/idle/blend_position", anim_direction)

# 	# Flip sprite when facing left
# 	if anim_direction.x < 0:
# 		facing_left = true
# 		$Sprite.flip_h = true
# 	elif anim_direction.x > 0:
# 		facing_left = false
# 		$Sprite.flip_h = false

# ===========================================


func set_controllable(value: bool) -> void:
	if current_player == value:
		return
	current_player = value


func get_input():
	direction = Input.get_vector("player_left", "player_right", "player_up","player_down")
	if !current_player:
		return

	# Manage press/release transitions
	for dir in DIRECTIONS:
		var action = "player_" + dir
		if Input.is_action_just_pressed(action):
			mover._move(dir)
		# 	_on_press_dir(dir)

		# 	# # Update last direction on key press
		# 	# match dir:
		# 	# 	"up": last_non_zero_direction = Vector2(0, -1)
		# 	# 	"down": last_non_zero_direction = Vector2(0, 1)
		# 	# 	"left": last_non_zero_direction = Vector2(-1, 0)
		# 	# 	"right": last_non_zero_direction = Vector2(1, 0)

		# elif Input.is_action_just_released(action):
		# 	_on_release_dir(dir)



# func _move(dir: String) -> void:
# 	# Don't start new move if already moving

# 	if is_moving:
# 		return

# 	var new_target := position
# 	match dir:
# 		"up": new_target.y -= CELL_SIZE
# 		"down": new_target.y += CELL_SIZE
# 		"left": new_target.x -= CELL_SIZE
# 		"right": new_target.x += CELL_SIZE

# 	if not _can_move_to(new_target):
# 		return

# 	# Set target and start moving
# 	target_position = new_target
# 	is_moving = true

# 	if current_player:
# 		SignalBus.current_player_moved.emit(self)


# func _on_press_dir(dir: String) -> void:
# 	_move_state[dir]["held"] = true
# 	_move_state[dir]["time"] = 0.0
# 	mover._move(dir) # immediate first step
# 	_move_state[dir]["next_emit"] = repeat_initial_delay

# func _on_release_dir(dir: String) -> void:
# 	_move_state[dir]["held"] = false
# 	_move_state[dir]["time"] = -1.0
# 	_move_state[dir]["next_emit"] = 0.0

func _process_held_movement(delta: float) -> void:
	if not current_player:
		return

	for dir in ["up", "down", "left", "right"]:
		# var state = _move_state[dir]
		mover._move(dir)
		# if state["held"] and state["time"] >= 0:
		# 	state["time"] += delta
		# 	if state["time"] >= state["next_emit"]:
		# 		mover._move(dir)
		# 		state["next_emit"] = state["time"] + repeat_interval

# func _process_smooth_movement(delta: float) -> void:
# 	if not is_moving:
# 		return

# 	position = position.move_toward(target_position, move_speed * delta)
# 	if position.distance_to(target_position) < 0.5:
# 		position = target_position
# 		is_moving = false

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

# TODO this also relies on a particular structure above it
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
