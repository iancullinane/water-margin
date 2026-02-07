extends Node2D


# func _physics_process(_delta: float) -> void:
# position = position.snapped(Vector2.ONE * tile_size)

@onready var entity: IEntity = get_parent()

var is_moving: bool = false
var target_position: Vector2
var move_speed: float = 150.0  # Pixels per second
var facing_left: bool = false  # Track if character is facing left for sprite flipping

func _ready() -> void:
	target_position = position  # Initialize to current position

func _move(dir: String) -> void:
	# Don't start new move if already moving

	if is_moving:
		return

	var new_target := position
	match dir:
		"up": new_target.y -= GameConstants.CELL_SIZE
		"down": new_target.y += GameConstants.CELL_SIZE
		"left": new_target.x -= GameConstants.CELL_SIZE
		"right": new_target.x += GameConstants.CELL_SIZE

	# if not _can_move_to(new_target):
	# 	return

	# Set target and start moving
	target_position = new_target
	is_moving = true

	# if current_player:
	# 	SignalBus.current_player_moved.emit(self)
