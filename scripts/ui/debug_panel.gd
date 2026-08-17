extends Panel
class_name DebugPanel


@onready var hovered_pos: Label = %HoveredPos
@onready var selected_player_pos: Label = %SelectedPlayerPos
@onready var player_name: Label = %CurrentPlayer
@onready var tile_data: Label = %TileData
@onready var mode: Label = %Mode

func get_hovered_pos() -> String:
	return hovered_pos.text

func set_hovered_pos(value: String) -> void:
	hovered_pos.text = value

func get_selected_player_pos() -> String:
	return selected_player_pos.text

func set_selected_player_pos(value: String) -> void:
	selected_player_pos.text = value

func get_player_name() -> String:
	return player_name.text

func set_player_name(value: String) -> void:
	player_name.text = value

func get_tile_data() -> String:
	return tile_data.text

func set_tile_data(value: String) -> void:
	tile_data.text = value

func update_hover(event_data: UiMainClickEvent) -> void:
	hovered_pos.text = "X: %s, Y: %s" % [event_data.coordinates.x, event_data.coordinates.y]
	if event_data.map:
		tile_data.text = "Mv: %s" % event_data.map.get_movement_cost(event_data.coordinates)

func update_player(entity: IEntity) -> void:
	player_name.text = entity.name
	var grid_pos = GameConstants.world_to_grid(entity.position)
	selected_player_pos.text = "Player: (%d, %d)" % [grid_pos.x, grid_pos.y]

func set_mode(value: String) -> void:
	mode.text = value
