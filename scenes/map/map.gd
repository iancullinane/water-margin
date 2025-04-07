extends Node2D
class_name GameMap

var last_hovered_coords: Vector2i = Vector2i(-999, -999)

# Realistically, the entities should not even be related to the map
# shit is fucked up
# TODO the entities are too tightly coupled to the map





func get_ground_layer()->TileMapLayer:
	return $Ground

func get_terrain_layer()->TileMapLayer:
	return $Terrain

#func _draw():
	#var tilemap_layer = get_ground_layer()
	#var mouse_pos = get_viewport().get_mouse_position()
	#var local_mouse = tilemap_layer.get_global_transform().affine_inverse() * mouse_pos
	#var coords = tilemap_layer.local_to_map(local_mouse)
	#var top_left = tilemap_layer.map_to_local(coords)
#
	#var tile_size = tilemap_layer.get_tile_map().tile_set.tile_size
	#draw_rect(Rect2(top_left, tile_size), Color.RED, false)
func update_ui_from_pos(map: GameMap, ui):
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
			ui.get_ground_display().text = tile_name
		else:
			ui.get_ground_display().text = "No data"
 
		if terrain_data and terrain_data.has_custom_data("name"):
			var tile_name: String = terrain_data.get_custom_data("name")
			ui.get_terrain_display().text = tile_name
		else:
			ui.get_terrain_display().text = "No data"
