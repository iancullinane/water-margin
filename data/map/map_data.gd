extends Resource
class_name GameMapData

@export var tile_data: Array[GameTile]


func get_tile(position: Vector2i) -> GameTile:
	for tile in tile_data:
		if tile.position == position:
			return tile
	return null
