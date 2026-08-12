extends CanvasLayer
class_name InGameMenu

const START_SCREEN := "res://scenes/start_screen.tscn"

@onready var save_btn: Button = %SaveButton
@onready var load_btn: Button= %LoadButton
@onready var quit_btn: Button = %QuitButton


func _ready() -> void:
	save_btn.pressed.connect(_on_save_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)


func _on_save_pressed() -> void:
	SignalBus.save_game.emit()


## Quit leaves the session and returns to the slot list rather than closing the
## app, so the player can pick another save without relaunching. Unsaved
## progress is discarded — saving is the explicit Save button above.
func _on_quit_pressed() -> void:
	logging.log("quitting to start screen")
	get_tree().change_scene_to_file(START_SCREEN)
