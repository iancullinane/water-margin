extends Node2D
class_name GameMap

var last_hovered_coords: Vector2i = Vector2i(-999, -999)


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