extends Resource
class_name GameMapData

@export var tile_data: Array[GameTile]
@export var map_size: Vector2i = Vector2i(100, 100)  # Width x Height in tiles
@export var map_offset: Vector2i = Vector2i.ZERO  # Top-left corner position
@export var highlighted_tile: Vector2i = Vector2i(-1, -1)  # Currently highlighted tile (-1,-1 = none)




func get_tile(position: Vector2i) -> GameTile:
	for tile in tile_data:
		if tile.position == position:
			return tile
	return null


func get_bounds_rect() -> Rect2i:
	"""Returns the bounding rectangle of this map"""
	return Rect2i(map_offset, map_size)


func contains_position(position: Vector2i) -> bool:
	"""Check if a tile position is within map bounds"""
	return get_bounds_rect().has_point(position)
