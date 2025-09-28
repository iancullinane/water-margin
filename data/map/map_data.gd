extends Resource
class_name GameMapData

@export var tile_data: Dictionary[Vector2i, GameTileData]


func get_tile(position: Vector2i) -> GameTileData:
	if not tile_data.has(position):
		return null
	return tile_data[position]
