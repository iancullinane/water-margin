extends CanvasLayer
class_name TileInfoUi


@onready var hovered_pos: Label = %HoveredPos
@onready var selected_player_pos: Label = %SelectedPlayerPos

var current_player_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	SignalBus.connect("hovered", processUI)
	SignalBus.connect("current_player_moved", _on_current_player_moved)

func processUI(event_data: UiEventData):
	if event_data:
		hovered_pos.text = "X: %s, Y: %s" % [event_data.coordinates.x, event_data.coordinates.y]
		if event_data.tile_data:
			hovered_pos.text += "\nTile Data: %s" % [event_data.tile_data.description]

func _on_current_player_moved(entity: Entity) -> void:
	if entity:
		current_player_position = entity.position
		_update_player_position_display()

func _update_player_position_display() -> void:
	if selected_player_pos:
		var tile_coords := _convert_global_to_tile_coords(current_player_position)
		selected_player_pos.text = "Player: (%d, %d)" % [tile_coords.x, tile_coords.y]

func _convert_global_to_tile_coords(global_pos: Vector2) -> Vector2i:
	var game_map := _get_current_map()
	if game_map:
		return game_map.get_tile_from_global(global_pos)
	else:
		var cell_size := GameConstants.CELL_SIZE
		return Vector2i(
			int(floor(global_pos.x / cell_size)),
			int(floor(global_pos.y / cell_size))
		)

func _get_current_map() -> GameMap:
	var level_loader = get_tree().root.find_child("LevelLoader", true, false)
	if level_loader and level_loader.has_method("get_current_map"):
		return level_loader.get_current_map()
	return null
