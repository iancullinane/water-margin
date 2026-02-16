extends Panel
class_name PlayerInfoCard

@onready var portrait: TextureRect = $MarginContainer/PlayerInfoV/PortraitMargin/Portrait
@onready var name_label: Label = $MarginContainer/PlayerInfoV/Info/NameLabel
@onready var dmg_label: Label = $MarginContainer/PlayerInfoV/Info2/DmgLabel

func _ready() -> void:
	SignalBus.current_player_changed.connect(_on_current_player_changed)

func _on_current_player_changed(entity: IEntity) -> void:
	if entity.stats and entity.stats.portrait:
		portrait.texture = entity.stats.portrait

func set_name_label(text: String) -> void:
	name_label.text = text

func get_name_label() -> String:
	return name_label.text

func set_dmg_label(text: String) -> void:
	dmg_label.text = text

func get_dmg_label() -> String:
	return dmg_label.text
