# @tool
extends Node2D


@export var player: Node2D
@export var map_ctl: MapCtl

var last_hovered_coords: Vector2i = Vector2i(-999, -999)

func _ready():
	if not map_ctl:
		map_ctl = get_parent().get_node("MapCtl")

func _process(_delta:float) -> void:
	handle_hover_data(get_global_mouse_position())


func handle_hover_data(focus: Vector2):
	var tile_coords := GameConstants.world_to_grid(focus)
	if tile_coords != last_hovered_coords:
		last_hovered_coords = tile_coords
		var ui_event = UiMainClickEvent.from_coordinates(tile_coords) \
			.with_map(map_ctl.get_current_map())

		# This doesn't work in editor because they signal bus isn't available
		# ERROR: res://scripts/components/game_focus.gd:40 - Invalid access to property or key 'hovered' on a base object of type 'Node (signal_bus.gd)'.
		SignalBus.hovered.emit(ui_event)
