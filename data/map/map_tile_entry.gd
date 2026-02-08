extends Resource
class_name MapTileEntry

## A single entry mapping a position to tile data
## This makes it easy to edit in the Godot inspector

@export var position: Vector2i = Vector2i(0, 0)
@export var tile: GameTile

func _init(pos: Vector2i = Vector2i(0, 0), tile_data: GameTile = null) -> void:
	position = pos
	tile = tile_data

