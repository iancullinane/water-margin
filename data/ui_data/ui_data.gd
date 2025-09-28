extends Resource
class_name UiEventData

## Resource class for storing and managing UI event data related to ground and terrain layers.
## Used to communicate tile data information to the UI system.

const DEFAULT_NO_DATA: String = "No data"


var coordinates: Vector2i = Vector2i(0, 0)

var ground_layer_data: String = DEFAULT_NO_DATA
var terrain_layer_data: String = DEFAULT_NO_DATA

## Initialize the UI event data 
func _init(tile_coords: Vector2i) -> void:
	coordinates = tile_coords

static func from_coordinates(tile_coords: Vector2i) -> UiEventData:
	return UiEventData.new(tile_coords)
