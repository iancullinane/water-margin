extends Node2D

var CELL_SIZE = GameConstants.CELL_SIZE

@onready var entity: IEntity = get_parent()

var is_moving: bool = false
var target_position: Vector2
var move_speed: float = 150.0  # Pixels per second

func _ready() -> void:
	target_position = entity.position

func _physics_process(delta: float) -> void:
	if not is_moving:
		return

	var to_target := target_position - entity.position
	# Snap on the final tick so move_and_slide can never overshoot the cell.
	if to_target.length() <= move_speed * delta:
		entity.position = target_position
		entity.velocity = Vector2.ZERO
		is_moving = false
		SignalBus.current_player_moved.emit(entity)
	else:
		entity.velocity = to_target.normalized() * move_speed
		entity.move_and_slide()

func move(dir: Vector2) -> void:
	if is_moving:
		return

	target_position = entity.position + dir * CELL_SIZE
	is_moving = true
