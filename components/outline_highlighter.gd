extends Node
class_name TileHighlighter

@export var enabled: bool = true : set = _set_enabled
@export var base_layer : TileMapLayer
@export var highlight_layer : TileMapLayer 
@export var tile: Vector2i

# There is an important note here. The 0 is an index, if we were looking
# at the TileSet resource in the inspector, we would see a list of sources.
# The first source is the default one, and it has an index of 0.
# More here: https://youtu.be/4f1F86uytOA?list=PL6SABXRSlpH_0UEV3gJ53I7a2eGL8pqs3&t=2752
@onready var source_id := base_layer.tile_set.get_source_id(0)

func _process(_delta: float) -> void:
	if !enabled:
		return

	var selected_tile: Vector2i = base_layer.local_to_map(base_layer.get_local_mouse_position())

	_update_tile(selected_tile)


func _set_enabled(new_value: bool) -> void:
	enabled = new_value

	if !enabled and base_layer:
		highlight_layer.clear()

func _update_tile(selected_tile: Vector2i) -> void:
	highlight_layer.clear()
	highlight_layer.set_cell(selected_tile, source_id, tile)
