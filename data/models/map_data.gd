extends Resource
class_name GameMapData


@export var map_size: Vector2i = Vector2i(100, 100)  # Width x Height in tiles
@export var map_offset: Vector2i = Vector2i.ZERO  # Top-left corner position
@export var highlighted_tile: Vector2i = Vector2i(-1, -1)  # Currently highlighted tile (-1,-1 = none)
@export var tile_data: Array[GameTile]

## Get the GameTile for this set of data
func get_tile(position: Vector2i) -> GameTile:
	for tile in tile_data:
		if tile.position == position:
			return tile
	return null

## Returns the bounding rectangle of this map
func get_bounds_rect() -> Rect2i:

	return Rect2i(map_offset, map_size)

## Check if a tile position is within map bounds
func contains_position(position: Vector2i) -> bool:

	return get_bounds_rect().has_point(position)
