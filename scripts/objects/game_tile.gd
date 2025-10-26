extends Resource
class_name GameTile


@export var description: String

func event_from_coordinates(tile_coords: Vector2i) -> UiEventData:
	return UiEventData.new(tile_coords)