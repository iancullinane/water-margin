extends TileMapLayer
class_name GameMap

@export var map_name: String = "DEFAULT_MAP"
@export var game_map_data: GameMapData

@onready var ground_layer: TileMapLayer = $Ground
@onready var terrain_layer: TileMapLayer = $Terrain
@onready var buildings_layer: TileMapLayer = $Buildings
@onready var landmarks_layer: TileMapLayer = $Landmarks



var layer_dict = {
	"ground": $Ground,
	"terrain": $Terrain,
	"buildings": $Buildings,
	"landmarks": $Landmarks
}

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




func get_map_name() -> String:
	return map_name

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


## Returns the pixel-space bounding rect of all used tiles across all layers.
func get_map_pixel_rect() -> Rect2:
	var used := get_used_rect()
	for layer in get_tilemap_layers():
		used = used.merge(layer.get_used_rect())
	var cell_size := Vector2(GameConstants.CELL_SIZE, GameConstants.CELL_SIZE)
	return Rect2(Vector2(used.position) * cell_size, Vector2(used.size) * cell_size)


## Returns the movement cost at the given tile by checking all layers.
## If any layer has movement == 1 at this position, the tile is blocked.
func get_movement_cost(tile_coords: Vector2i) -> int:
	# Check the root layer (GameMap itself is a TileMapLayer)
	var root_data := get_cell_tile_data(tile_coords)
	if root_data and root_data.get_custom_data("movement") == 1:
		return 1
	for layer in get_tilemap_layers():
		var tile_data := layer.get_cell_tile_data(tile_coords)
		if tile_data and tile_data.get_custom_data("movement") == 1:
			return 1
	return 0
