extends Resource
class_name GameMapData

@export var tile_data: Dictionary[Vector2i, GameTile]


func get_tile(position: Vector2i) -> GameTile:
	if not tile_data.has(position):
		return null
	return tile_data[position]
