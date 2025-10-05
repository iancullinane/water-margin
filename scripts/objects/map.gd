extends TileMapLayer
class_name GameMap

@export var game_map_data: GameMapData

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

func get_building_layer()->TileMapLayer:
	return $Buildings




# getting the hovered tile
func get_tile_from_global(global: Vector2) -> Vector2i:
	return local_to_map(to_local(global))

func get_global_from_tile(tile: Vector2i) -> Vector2:
	return to_global(map_to_local(tile))

func get_hovered_tile() -> Vector2i:
	return local_to_map(get_local_mouse_position())

func get_game_map_data() -> GameMapData:
	return game_map_data

func get_tile_data_at(tile_coords: Vector2i) -> GameTile:
	if game_map_data == null:
		return null
	return game_map_data.get_tile(tile_coords)
