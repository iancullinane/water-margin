extends CanvasLayer
class_name TileInfoUi


@onready var hovered_pos: Label = %HoveredPos
@onready var selected_player_pos: Label = %SelectedPlayerPos




@onready var tile_flavor: Panel = $TileFlavor
@onready var tile_description: RichTextLabel = $TileFlavor/Margin/Description

@onready var player_name: Label = %CurrentPlayer
@onready var tile_data: Label = %TileData

func _ready() -> void:
	if not Engine.is_editor_hint():
		tile_flavor.visible = false
	SignalBus.connect("hovered", processMainCickAndCurrentlyHover)
	SignalBus.connect("current_player_moved", _on_current_player_moved)
	# if SignalBus.has_signal("current_player_changed"):
	SignalBus.current_player_changed.connect(_on_current_player_changed)

func processMainCickAndCurrentlyHover(event_data: UiMainClickEvent):
	if event_data:
		hovered_pos.text = "X: %s, Y: %s" % [event_data.coordinates.x, event_data.coordinates.y]
		if event_data.tile_data:
			hovered_pos.text += "\nTile Data: %s" % [event_data.tile_data.description]
	if event_data.map:
		var movement_cost_text = "Mv: %s" % event_data.map.get_movement_cost(event_data.coordinates)
		tile_data.text = movement_cost_text


func _on_current_player_changed(entity: IEntity):
	player_name.text = entity.name
	var player_position = GameConstants.world_to_grid(entity.position)
	_update_player_position_display(player_position)

func _on_current_player_moved(entity: IEntity) -> void:

	if entity == null:
		return

	var player_position = GameConstants.world_to_grid(entity.position)
	_update_player_position_display(player_position)

func _update_player_position_display(grid_position: Vector2) -> void:
	selected_player_pos.text = "Player: (%d, %d)" % [grid_position.x, grid_position.y]

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
