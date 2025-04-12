extends Node2D

@onready var game = $Game 
@onready var map_from_game = game.get_map()
@onready var main_ui := $MainUi

var last_hovered_coords: Vector2i = Vector2i(-999, -999)

func _process(_delta):
	handle_hover_data(map_from_game)
	# if tile_coords != last_hovered_coords:

func handle_hover_data(map: GameMap):
	var ground_layer: TileMapLayer = map.get_ground_layer()
	var terrain_layer: TileMapLayer = map.get_terrain_layer()
	var local_pos = ground_layer.to_local(get_global_mouse_position())
	var tile_coords = ground_layer.local_to_map(local_pos)
	
	if tile_coords != last_hovered_coords:
		last_hovered_coords = tile_coords
		var ground_data = ground_layer.get_cell_tile_data(tile_coords)
		var terrain_data = terrain_layer.get_cell_tile_data(tile_coords)
		
		var ui_data = UiEventData.new()
		ui_data.set_from_tile_data(ground_data, terrain_data)
		SignalBus.hovered.emit(ui_data)
