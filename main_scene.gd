extends Node2D

@onready var game = $Game 
@onready var map = game.get_map()

@onready var main_ui := $MainUi
@onready var info_box := main_ui.get_node("PanelContainer/NinePatchRect/HeaderText")

var last_hovered_coords: Vector2i = Vector2i(-999, -999)

func _process(_delta):
	#update_tile_hover_info()
	handle_hover_data(map)

func handle_hover_data(map: GameMap):
	var ground_layer: TileMapLayer = map.get_ground_layer()
	var terrain_layer: TileMapLayer = map.get_terrain_layer()
	var local_pos = ground_layer.to_local(get_global_mouse_position())
	var tile_coords = ground_layer.local_to_map(local_pos)
	
	if tile_coords != last_hovered_coords:
		last_hovered_coords = tile_coords
		var ground_data = ground_layer.get_cell_tile_data(tile_coords)
		var terrain_data = terrain_layer.get_cell_tile_data(tile_coords)

		if ground_data and ground_data.has_custom_data("name"):
			var tile_name: String = ground_data.get_custom_data("name")
			main_ui.get_ground_display().text = tile_name
		else:
			main_ui.get_ground_display().text = "No data"
 
		if terrain_data and terrain_data.has_custom_data("name"):
			var tile_name: String = terrain_data.get_custom_data("name")
			main_ui.get_terrain_display().text = tile_name
		else:
			main_ui.get_terrain_display().text = "No data"
