extends TileMapLayer
class_name GameMap

@export var map_name: String = "DEFAULT_MAP"
@export var game_map_data: GameMapData

@onready var ground_layer: TileMapLayer = $Ground
@onready var terrain_layer: TileMapLayer = $Terrain
@onready var buildings_layer: TileMapLayer = $Buildings
@onready var landmarks_layer: TileMapLayer = $Landmarks

# Registry built from the root TileSet in _ready().
# Maps tile "name" custom data value -> {source_id, coords}.
# Populated from all atlas sources on the root Map node's TileSet.
var _named_tiles: Dictionary = {}


func _ready() -> void:
	_build_named_tile_registry()
	apply_map_data(game_map_data)
	print(JSON.stringify(_named_tiles, "\t"))


## Scans the root Map node's TileSet and builds a lookup of all tiles
## that have a non-empty "name" custom data value.
## Result: _named_tiles[name] = {source_id: int, coords: Vector2i}
func _build_named_tile_registry() -> void:
	_named_tiles.clear()
	if tile_set == null:
		return
	if tile_set.get_custom_data_layer_by_name("name") == -1:
		push_warning("GameMap: TileSet has no custom data layer named 'name'")
		return
	for i in tile_set.get_source_count():
		var sid := tile_set.get_source_id(i)
		var src := tile_set.get_source(sid)
		if not src is TileSetAtlasSource:
			continue
		var atlas := src as TileSetAtlasSource
		for j in atlas.get_tiles_count():
			var coords := atlas.get_tile_id(j)
			var td := atlas.get_tile_data(coords, 0)
			if td == null:
				continue
			var tile_name: String = td.get_custom_data("name")
			if tile_name != "":
				_named_tiles[tile_name] = {"source_id": sid, "coords": coords}


## Places tiles from GameMapData that have a cell_image_name onto the
## child layer named by game_tile.target_layer.
func apply_map_data(data: GameMapData) -> void:
	game_map_data = data
	for game_tile in data.tile_data:
		if game_tile.cell_image_name == "":
			print("no cell_image_name")
			continue
		var entry: Dictionary = _named_tiles.get(game_tile.cell_image_name, {})
		if entry.is_empty():
			push_warning("GameMap: no named tile '%s' in TileSet" % game_tile.cell_image_name)
			continue
		var layer := get_node_or_null(game_tile.target_layer) as TileMapLayer
		if layer == null:
			push_warning("GameMap: no child layer '%s'" % game_tile.target_layer)
			continue
		layer.set_cell(game_tile.position, entry["source_id"], entry["coords"])


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

# ================================================
# Mouse position functions
# ================================================

# getting the hovered tile
func get_tile_from_global(global: Vector2) -> Vector2i:
	return local_to_map(to_local(global))

func get_global_from_tile(tile: Vector2i) -> Vector2:
	return to_global(map_to_local(tile))

## Get the tile the mouse is currently over
func get_hovered_tile() -> Vector2i:
	return local_to_map(get_local_mouse_position())

## Get the game map data
func get_game_map_data() -> GameMapData:
	return game_map_data

## Get the GameTile for a particular coordinate
func get_tile_data_at(tile_coords: Vector2i) -> GameTile:
	if game_map_data == null:
		return null
	return game_map_data.get_tile(tile_coords)

# ================================================

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
