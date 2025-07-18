extends Node2D
class_name GameMap

func get_tilemap_layers() -> Array[TileMapLayer]:
	var layers: Array[TileMapLayer] = []
	for child in get_children():
		if child is TileMapLayer:
			layers.append(child)
	return layers

func get_ground_layer()->TileMapLayer:
	return $Ground

func get_terrain_layer()->TileMapLayer:
	return $Terrain
