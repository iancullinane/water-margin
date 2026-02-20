extends Resource
class_name GameTile

@export var position: Vector2i
@export var description: String

# func event_from_coordinates(tile_coords: Vector2i) -> UiMainClickEvent:
# 	return UiMainClickEvent.new(tile_coords)
@export var cell_image_name: String
