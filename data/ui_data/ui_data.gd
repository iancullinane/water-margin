extends Resource
class_name UiEventData

var ground_layer_data: String = "No data"
var terrain_layer_data: String = "No data"

func _init(gd: String = "No data", td: String = "No data"):
	set_ground_data(gd)
	set_terrain_data(td)

func set_ground_data(data: String) -> void:
	ground_layer_data = data if data != "" else "No data"

func set_terrain_data(data: String) -> void:
	terrain_layer_data = data if data != "" else "No data"

func set_from_tile_data(ground_data: TileData, terrain_data: TileData) -> void:
	if ground_data and ground_data.has_custom_data("name"):
		set_ground_data(ground_data.get_custom_data("name"))
	
	if terrain_data and terrain_data.has_custom_data("name"):
		set_terrain_data(terrain_data.get_custom_data("name"))
