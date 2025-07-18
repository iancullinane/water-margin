extends Resource
class_name UiEventData

## Resource class for storing and managing UI event data related to ground and terrain layers.
## Used to communicate tile data information to the UI system.

const DEFAULT_NO_DATA: String = "No data"

@export var ground_layer_data: String = DEFAULT_NO_DATA
@export var terrain_layer_data: String = DEFAULT_NO_DATA

## Initialize the UI event data with optional ground and terrain data
## @param gd: Ground layer data string
## @param td: Terrain layer data string
func _init(gd: String = DEFAULT_NO_DATA, td: String = DEFAULT_NO_DATA) -> void:
	set_ground_data(gd)
	set_terrain_data(td)

## Create a new UiEventData instance from TileData objects
## @param ground_data: The ground layer TileData
## @param terrain_data: The terrain layer TileData
## @return: A new UiEventData instance
static func from_tile_data(ground_data: TileData, terrain_data: TileData) -> UiEventData:
	var instance = UiEventData.new()
	instance.set_from_tile_data(ground_data, terrain_data)
	return instance

## Set the ground layer data
## @param data: The ground layer data string to set
func set_ground_data(data: String) -> void:
	ground_layer_data = data if data != "" else DEFAULT_NO_DATA

## Set the terrain layer data
## @param data: The terrain layer data string to set
func set_terrain_data(data: String) -> void:
	terrain_layer_data = data if data != "" else DEFAULT_NO_DATA

## Set data from TileData objects
## @param ground_data: The ground layer TileData
## @param terrain_data: The terrain layer TileData
func set_from_tile_data(ground_data: TileData, terrain_data: TileData) -> void:
	if ground_data != null and ground_data.has_custom_data("name"):
		set_ground_data(ground_data.get_custom_data("name"))
	else:
		set_ground_data(DEFAULT_NO_DATA)
	
	if terrain_data != null and terrain_data.has_custom_data("name"):
		set_terrain_data(terrain_data.get_custom_data("name"))
	else:
		set_terrain_data(DEFAULT_NO_DATA)
