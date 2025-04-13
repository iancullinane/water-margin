extends Node2D

@export var use_mouse_focus: bool = true
@export var attach_to_player: bool = false

@export var map_from_game: GameMap

var last_hovered_coords: Vector2i = Vector2i(-999, -999)

func _process(_delta:float) -> void:
	if use_mouse_focus:
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
