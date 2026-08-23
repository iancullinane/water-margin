extends Panel
class_name PlayerInfoCard

@onready var portrait: TextureRect = $MarginContainer/PlayerInfoV/PortraitMargin/Panel/MarginContainer/Portrait
@onready var name_label: Label = %NameLabel
@onready var mvt_label: Label = $MarginContainer/PlayerInfoV/Info2/DmgLabel

func _ready() -> void:
	SignalBus.current_player_changed.connect(_on_current_player_changed)

func _on_current_player_changed(entity: IEntity) -> void:
	if entity.stats and entity.stats.portrait:
		portrait.texture = entity.stats.portrait
		name_label.text = entity.stats.name
		mvt_label.text = str(entity.stats.movement_range())


func set_name_label(text: String) -> void:
	name_label.text = text

func get_name_label() -> String:
	return name_label.text

func set_dmg_label(text: String) -> void:
	mvt_label.text = text

func get_dmg_label() -> String:
	return mvt_label.text
