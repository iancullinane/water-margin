## The base entity from which other entities are derived
## does not handle input, but does handle the actions of
## an entity so that NPC's can share
extends Node2D
class_name IEntity

func is_entity():
	return true


@export var stats:EntityData
@onready var name_label = $NameLabel
@onready var animation_player = $AnimationPlayer
@onready var mover = $Mover

var CELL_SIZE = GameConstants.CELL_SIZE


# Player movement variables
# ========================
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
	snap_to_grid()

func snap_to_grid() -> void:
	position = position.snapped(Vector2(CELL_SIZE, CELL_SIZE))
	target_position = position

func get_stat(stat_name: String) -> String:
	match stat_name:
		"damage":
			if stats and stats.job_data:
				return str(stats.job_data.damage)
		"name":
			if stats:
				return stats.name
	return ""


# func _physics_process(_delta: float) -> void:
# 	_process_held_movement(_delta)
	# _process_smooth_movement(_delta)
	# set_animation()

	# if current_player:
	# 	get_input()

# func set_animation():

# 	# Store last non-zero direction when moving
# 	if direction.length() > 0:
# 		last_non_zero_direction = direction


# 	# Manage press/release transitions
# 	for dir in DIRECTIONS:
# 		var action = "player_" + dir
# 		if Input.is_action_just_pressed(action):
# 			mover._move(dir)
		# 	_on_press_dir(dir)

		# 	# # Update last direction on key press
		# 	# match dir:
		# 	# 	"up": last_non_zero_direction = Vector2(0, -1)
		# 	# 	"down": last_non_zero_direction = Vector2(0, 1)
		# 	# 	"left": last_non_zero_direction = Vector2(-1, 0)
		# 	# 	"right": last_non_zero_direction = Vector2(1, 0)

		# elif Input.is_action_just_released(action):
		# 	_on_release_dir(dir)


## step performs one grid move via the Mover. The entity only knows about
## itself — terrain and occupancy validation belong to the controller
## (see EntityCtl.try_move), so entities stay self-contained and reusable
## for both players and NPCs.
func step(dir: Vector2) -> bool:
	if mover.is_moving:
		return false
	direction = dir
	mover.move(dir)
	return true



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

func _process_held_movement(_delta: float) -> void:
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

