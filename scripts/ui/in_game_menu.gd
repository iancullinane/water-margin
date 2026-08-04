extends CanvasLayer
class_name InGameMenu

@onready var save_btn: Button = %SaveButton
@onready var load_btn: Button= %LoadButton


func _ready() -> void:
	save_btn.pressed.connect(_on_save_pressed)


func _on_save_pressed() -> void:
	SignalBus.save_game.emit()
