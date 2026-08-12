## The base entity from which other entities are derived
## does not handle input, but does handle the actions of
## an entity so that NPC's can share
extends CharacterBody2D
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

# Smooth movement variables
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_size_collision_shape()
	snap_to_grid()

## The scene bakes a static shape, but the grid is the source of truth —
## re-derive size and placement from CELL_SIZE so they can't drift apart.
## Slightly under a full cell so adjacent entities' shapes never touch.
func _size_collision_shape() -> void:
	var cs := get_node_or_null("CollisionShape2D")
	if cs == null or not cs.shape is RectangleShape2D:
		return
	cs.shape.size = Vector2.ONE * (CELL_SIZE - 2)
	cs.position = Vector2.ONE * (CELL_SIZE / 2.0)

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

func on_save_game(saved_data:Array[SavedData]):
	logging.log("Save %s" % stats.name)
	var my_data = SavedData.new()
	my_data.position = position
	my_data.scene_path = scene_file_path
	my_data.direction = direction

	saved_data.append(my_data)

func on_load_game(saved_data: SavedData):
	position = saved_data.position
	direction = saved_data.direction
