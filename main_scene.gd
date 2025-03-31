extends Node2D

@onready var game = $Game 
@onready var map = game.get_map()

@onready var main_ui := $MainUi
@onready var info_box := main_ui.get_node("InfoBox/HeaderText")

var last_hovered_coords: Vector2i = Vector2i(-999, -999)

func _process(_delta):
	update_tile_hover_info()

#func get_hovered_tile_coords(tilemap_layer: TileMapLayer) -> Vector2i:
	#var global_mouse_pos = get_viewport().get_mouse_position()
	#var local_mouse_pos = tilemap_layer.get_global_transform().affine_inverse() * global_mouse_pos
	#var tile_coords = tilemap_layer.local_to_map(local_mouse_pos)
	#return tile_coords

func update_tile_hover_info():
	var ground_layer: TileMapLayer = map.get_ground_layer()
	var local_pos = ground_layer.to_local(get_global_mouse_position())
	var tile_coords = ground_layer.local_to_map(local_pos)
	
	if tile_coords != last_hovered_coords:
		last_hovered_coords = tile_coords
		var data = ground_layer.get_cell_tile_data(tile_coords)

		if data and data.has_custom_data("name"):
			var tile_name: String = data.get_custom_data("name")
			print("Data:", data)
			info_box.text = tile_name
		else:
			info_box.text = "No data"
 
