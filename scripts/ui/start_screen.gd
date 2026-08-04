@tool
extends Control

## The start screen. Lists save slots as selectable rows and hands the chosen
## one to SaveCtl before entering the game. The slot travels through the
## autoload, so change_scene_to_file needs no arguments.

const GAME_SCENE := "res://scenes/game.tscn"

@onready var saved_games_container = %SavedGameContainer
@onready var saved_games_list: VBoxContainer = %SavedGameContainer/SavedGames
@onready var new_game_button: Button = $CenterContainer/StartMenu/VBoxContainer/NewGameButton
@onready var load_button: Button = $CenterContainer/StartMenu/VBoxContainer/LoadButton

# Shared by every slot row so exactly one can be selected at a time.
var _slot_group := ButtonGroup.new()


func _ready():
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_button.pressed.connect(_on_load_pressed)
	_slot_group.pressed.connect(_on_slot_selected)

	if not Engine.is_editor_hint():
		_populate_saved_games()

	# Nothing is selected on entry, so there is nothing to load yet.
	load_button.disabled = true


func _populate_saved_games() -> void:
	# Clear the placeholder rows authored in the scene.
	for child in saved_games_list.get_children():
		child.queue_free()

	for slot in SaveCtl.list_slots():
		var row := Button.new()
		row.text = slot.display_name
		row.toggle_mode = true
		row.button_group = _slot_group
		# The path rides along with the row so selection needs no index
		# bookkeeping against the list.
		row.set_meta("slot_path", slot.path)
		saved_games_list.add_child(row)


func _on_slot_selected(_button: BaseButton) -> void:
	load_button.disabled = false


## New Game always mints a fresh slot, so it never overwrites an existing save.
func _on_new_game_pressed() -> void:
	logging.log("new game pressed")
	SaveCtl.new_slot()
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_load_pressed() -> void:
	var selected := _slot_group.get_pressed_button()
	if selected == null:
		return

	var slot_path: String = selected.get_meta("slot_path")
	logging.log("loading slot %s" % slot_path)
	SaveCtl.select_slot(slot_path)
	get_tree().change_scene_to_file(GAME_SCENE)
