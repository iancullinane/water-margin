#@tool
extends Node2D




@export var use_mouse_focus: bool = true
@export var attach_to_player: bool = false

# @export var map_from_game: GameMap
@export var player: Entity

# var ground_layer: TileMapLayer
# var terrain_layer: TileMapLayer
# var building_layer: TileMapLayer
# var highlight_layer: TileMapLayer


var game_node: Node2D



var last_hovered_coords: Vector2i = Vector2i(-999, -999)

# func _ready() -> void:
	
# 	ground_layer = map_from_game.get_ground_layer()
# 	terrain_layer = map_from_game.get_terrain_layer()
# 	building_layer = map_from_game.get_building_layer()
# 	# highlight_layer = map_from_game.get_highlight_layer()
# 	game_node = get_parent()



func _process(_delta:float) -> void:
	if Engine.is_editor_hint():
		# Always use mouse focus in editor
		handle_hover_data(get_global_mouse_position())
	else:
		# Runtime behavior based on export variables
		if use_mouse_focus:
			handle_hover_data(get_global_mouse_position())
		
		if attach_to_player:
			handle_hover_data(player.position)

func handle_hover_data(focus: Vector2):
	var cell_size := GameConstants.CELL_SIZE
	var local_pos := to_local(focus)
	var tile_coords := Vector2i(
		int(floor(local_pos.x / cell_size)),
		int(floor(local_pos.y / cell_size))
	)
	if tile_coords != last_hovered_coords:
		last_hovered_coords = tile_coords
		var ui_event = UiEventData.from_coordinates(tile_coords)
		SignalBus.hovered.emit(ui_event)
