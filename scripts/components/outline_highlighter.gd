@tool
extends Node
class_name TileHighlighter

@export var enabled: bool = true : set = _set_enabled
@export var tile: Vector2i = Vector2i(2, 2)

var base_layer: TileMapLayer
var highlight_layer: TileMapLayer
var source_id: int

func _ready() -> void:
	_setup_layers()

func _setup_layers() -> void:
	# Get parent as base layer
	if get_parent() is TileMapLayer:
		base_layer = get_parent() as TileMapLayer
	else:
		push_error("TileHighlighter parent must be a TileMapLayer")
		return

	# Look for Highlight child in parent
	if base_layer.has_node("Highlight"):
		highlight_layer = base_layer.get_node("Highlight") as TileMapLayer
	else:
		push_error("TileHighlighter requires a 'Highlight' TileMapLayer child in parent")
		return

	# Get source ID from base layer's tileset
	if base_layer.tile_set:
		source_id = base_layer.tile_set.get_source_id(0)

func _process(_delta: float) -> void:
	if !enabled or !base_layer or !highlight_layer:
		return

	var selected_tile: Vector2i = base_layer.local_to_map(base_layer.get_local_mouse_position())
	_update_tile(selected_tile)

func _set_enabled(new_value: bool) -> void:
	enabled = new_value

	if !enabled and highlight_layer:
		highlight_layer.clear()

func _update_tile(selected_tile: Vector2i) -> void:
	highlight_layer.clear()
	highlight_layer.set_cell(selected_tile, source_id, tile)
