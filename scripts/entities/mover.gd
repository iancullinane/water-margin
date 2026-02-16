extends Node2D

var CELL_SIZE = GameConstants.CELL_SIZE

@onready var entity: IEntity = get_parent()

var is_moving: bool = false
var target_position: Vector2
var move_speed: float = 150.0  # Pixels per second

func _ready() -> void:
	target_position = entity.position

func _process(delta: float) -> void:
	if not is_moving:
		return

	entity.position = entity.position.move_toward(target_position, move_speed * delta)
	if entity.position.distance_to(target_position) < 0.5:
		entity.position = target_position
		is_moving = false
		SignalBus.current_player_moved.emit(entity)

func move(dir: Vector2) -> void:
	if is_moving:
		return

	target_position = entity.position + dir * CELL_SIZE
	is_moving = true
