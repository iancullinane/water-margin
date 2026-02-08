@tool
extends Node2D
class_name Entity_V2


@export var stats:EntityData
@export var entity_ctl:EntityCtl

var CELL_SIZE = GameConstants.CELL_SIZE


@onready var name_label = $NameLabel
@onready var animation_player = $AnimationPlayer

var current_player: bool = false


func _ready() -> void:
	if entity_ctl == null:
		entity_ctl = get_parent()
	animation_player.play("idle_down")


# Player Movement
#
# Basic Movement
# ==============

func _on_move(direction):
	_move(direction)

# This is no longer a mobile game at all, remove touch
# func _on_swipe(direction):
# 	_move(direction)

func _move(dir: String) -> void:
	var target_pos := position

	# Movement is based on the size of cells
	if dir == "up":
		target_pos.y -= CELL_SIZE
	elif dir == "down":
		target_pos.y += CELL_SIZE
	elif dir == "left":
		target_pos.x -= CELL_SIZE
	elif dir == "right":
		target_pos.x += CELL_SIZE


	# if not _can_move_to(target_pos):
	# 	return

	# if dir == "up":
	# 	sprite.animation = "up_idle"
	# elif dir == "down":
	# 	sprite.animation = "down_idle"
	# elif dir == "left":
	# 	sprite.animation = "left_idle"
	# elif dir == "right":
	# 	sprite.animation = "right_idle"

	position = target_pos

	# if current_player:
	# 	SignalBus.current_player_moved.emit(self)


#
# Map
# This would work, but it depends on a node structure that
# needs to exist independently of itself. In the very least
# it should depend on the `EntityCtl` above it
#
#

func _get_current_map() -> GameMap:
	var level_loader = get_tree().root.find_child("LevelLoader", true, false)
	if level_loader and level_loader.has_method("get_current_map"):
		return level_loader.get_current_map()
	return null







# func _can_move_to(target_pos: Vector2) -> bool:
# 	var game_map := _get_current_map()
# 	if game_map == null:
# 		return true

# 	var tile_coords := game_map.get_tile_from_global(target_pos)

# 	if _is_tile_blocked(game_map, tile_coords):
# 		return false

# 	if _is_entity_at_position(target_pos):
# 		return false

# 	return true


# Zoom
# TODO: Implement
# ====

# func _on_zoom(direction):
# 	if direction == "in":
# 		zoom_in()
# 	elif direction == "out":
# 		zoom_out()


# func _input(event):

# 	if event.is_action("zoom_in"):
# 		emit_signal("zoomed", "in")

# 	if event.is_action("zoom_out"):
# 		emit_signal("zoomed", "out")
