# @tool
extends Node2D

@export var player: Node2D

var last_hovered_coords: Vector2i = Vector2i(-999, -999)

func _process(_delta:float) -> void:
	handle_hover_data(get_global_mouse_position())




func handle_hover_data(focus: Vector2):
	var parent_node := get_parent()
	var tile_coords: Vector2i
	if parent_node != null and parent_node.has_method("local_to_map") and parent_node.has_method("to_local"):
		print("using local_to_map")

	# Here we are using the base Node2D methods
	if parent_node != null and parent_node.has_method("local_to_map") and parent_node.has_method("to_local"):
		var local_pos: Vector2 = parent_node.to_local(focus)
		tile_coords = parent_node.local_to_map(local_pos)
	else:
		# Fallback to manual calculation if parent doesn't provide conversion methods
		var cell_size := GameConstants.CELL_SIZE
		var local_pos: Vector2 = to_local(focus)
		tile_coords = Vector2i(
			int(floor(local_pos.x / cell_size)),
			int(floor(local_pos.y / cell_size))
		)
	if tile_coords != last_hovered_coords:
		last_hovered_coords = tile_coords
		var ui_event = UiEventData.from_coordinates(tile_coords)

		# This doesn't work in editor because they signal bus isn't available
		# ERROR: res://scripts/components/game_focus.gd:40 - Invalid access to property or key 'hovered' on a base object of type 'Node (signal_bus.gd)'.
		SignalBus.hovered.emit(ui_event)
