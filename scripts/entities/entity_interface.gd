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

# Smooth movement variables
var target_position: Vector2 = Vector2.ZERO

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


# func on_save_game(saved_game:Array[SavedData])
