extends CanvasLayer
class_name TileInfoCtl


@onready var debug_panel: DebugPanel = %DebugPanel

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

func _on_current_player_changed(entity: IEntity):
	debug_panel.update_player(entity)

func _on_current_player_moved(entity: IEntity) -> void:
	if entity == null:
		return
	debug_panel.update_player(entity)
