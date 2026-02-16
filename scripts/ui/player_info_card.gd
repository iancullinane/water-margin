extends Panel
class_name PlayerInfoCard

@onready var portrait: TextureRect = $MarginContainer/PlayerInfoV/PortraitMargin/Portrait

func _ready() -> void:
	SignalBus.current_player_changed.connect(_on_current_player_changed)

func _on_current_player_changed(entity: IEntity) -> void:
	if entity.stats and entity.stats.portrait:
		portrait.texture = entity.stats.portrait
