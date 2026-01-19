extends Node2D
class_name IEntity

func is_entity():
	return true


@export var stats:EntityData
@export var entity_ctl:EntityCtl
@onready var name_label = $NameLabel
@onready var animation_player = $AnimationPlayer

var CELL_SIZE = GameConstants.CELL_SIZE

# Player movement variables
# ========================
var current_player: bool = false
var direction: Vector2

# Repeat configuration for held movement
# Entities move only "square-by-square" so we keep track of this stuff
# and only initiate moves from square to square
var repeat_initial_delay: float = 0.20 # this is how long to wait before repeating a direction
var repeat_interval: float = 0.33 # this adjusts speed when holding down a direction

# Internal held-state tracking
var _move_state := {
	"up": {"held": false, "time": -1.0, "next_emit": 0.0},
	"down": {"held": false, "time": -1.0, "next_emit": 0.0},
	"left": {"held": false, "time": -1.0, "next_emit": 0.0},
	"right": {"held": false, "time": -1.0, "next_emit": 0.0}
}

# ===========================================


func _ready() -> void:
	add_to_group("entities")
	print("Entity ready:", name, stats)
	# if the EntityCtl was not set in editor
	# it will expect the parent to be EntityCtl
	if entity_ctl == null:
		entity_ctl = get_parent()
	animation_player.play("idle_down")

func _physics_process(_delta: float) -> void:
	get_input()
	_process_held_movement(_delta)


func set_controllable(value: bool) -> void:
	if current_player == value:
		return
	current_player = value


func get_input():
	direction = Input.get_vector("left", "right", "up","down")
	if !current_player:
		return

	# Manage press/release transitions
	# TODO this can probably be simpler, they are already
	# facing the correct direction
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



func _move(dir: String) -> void:
	var target_pos := position
	match dir:
		"up": target_pos.y -= CELL_SIZE
		"down": target_pos.y += CELL_SIZE
		"left": target_pos.x -= CELL_SIZE
		"right": target_pos.x += CELL_SIZE

	if not _can_move_to(target_pos):
		return

	# Actually move!
	position = target_pos

	if current_player:
		SignalBus.current_player_moved.emit(self)


func _on_press_dir(dir: String) -> void:
	_move_state[dir]["held"] = true
	_move_state[dir]["time"] = 0.0
	_move(dir) # immediate first step
	_move_state[dir]["next_emit"] = repeat_initial_delay

func _on_release_dir(dir: String) -> void:
	_move_state[dir]["held"] = false
	_move_state[dir]["time"] = -1.0
	_move_state[dir]["next_emit"] = 0.0

func _process_held_movement(delta: float) -> void:
	if not current_player:
		return

	for dir in ["up", "down", "left", "right"]:
		var state = _move_state[dir]
		if state["held"] and state["time"] >= 0:
			state["time"] += delta
			if state["time"] >= state["next_emit"]:
				_move(dir)
				state["next_emit"] = state["time"] + repeat_interval

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
