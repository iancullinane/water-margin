extends Resource
class_name UiMainClickEvent

## Resource class for storing and managing UI event data related to ground and terrain layers.
## Used to communicate tile data information to the UI system.

const DEFAULT_NO_DATA: String = "No data"



var coordinates: Vector2i = Vector2i(0, 0)
var tile_data: GameTile = null
var map: GameMap = null
var player: Node2D = null

var ground_layer_data: String = DEFAULT_NO_DATA
var terrain_layer_data: String = DEFAULT_NO_DATA

## Initialize the UI event data
func _init(tile_coords: Vector2i) -> void:
	coordinates = tile_coords

func add_game_tile_data(game_tile_data: GameTile) -> void:
	self.tile_data = game_tile_data

func with_map(game_map: GameMap) -> UiMainClickEvent:
	map = game_map
	return self

func with_player(p: Node2D) -> UiMainClickEvent:
	player = p
	return self

static func from_coordinates(tile_coords: Vector2i) -> UiMainClickEvent:
	return UiMainClickEvent.new(tile_coords)

# we need to check for the map and return if null
func get_map() -> GameMap:
	if map == null:
		return null
	return map
