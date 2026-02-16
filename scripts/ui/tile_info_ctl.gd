extends CanvasLayer
class_name TileInfoCtl


@onready var debug_panel: DebugPanel = %DebugPanel

@onready var player_info_card: PlayerInfoCard = %PlayerInfoCard
@onready var tile_flavor: Panel = $TileFlavor
@onready var tile_description: RichTextLabel = $TileFlavor/Margin/Description


func _ready() -> void:
	if not Engine.is_editor_hint():
		tile_flavor.visible = false
	SignalBus.connect("hovered", _on_hovered)
	SignalBus.connect("current_player_moved", _on_current_player_moved)
	SignalBus.current_player_changed.connect(_on_current_player_changed)

func _on_hovered(event_data: UiMainClickEvent):
	if event_data:
		debug_panel.update_hover(event_data)
		if event_data.tile_data and event_data.tile_data.description != "":
			tile_description.text = event_data.tile_data.description
			tile_flavor.visible = true
		else:
			tile_flavor.visible = false

func _on_current_player_changed(entity: IEntity):
	debug_panel.update_player(entity)
	_update_player_info(entity)

func _on_current_player_moved(entity: IEntity) -> void:
	if entity == null:
		return
	debug_panel.update_player(entity)

func _update_player_info(entity: IEntity) -> void:
	if entity == null:
		return
	player_info_card.set_name_label(entity.get_stat("name"))
	player_info_card.set_dmg_label(entity.get_stat("damage"))
