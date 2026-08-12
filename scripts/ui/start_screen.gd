@tool
extends Control

## The start screen. Lists save slots as selectable rows and hands the chosen
## one to SaveCtl before entering the game. The slot travels through the
## autoload, so change_scene_to_file needs no arguments.

const GAME_SCENE := "res://scenes/game.tscn"

# Slot rows sit inside a small scroll list, so they read better below the
# theme's Button size. Themes have no percentage unit for font_size, so we
# scale the inherited value at build time instead of hardcoding a number —
# retuning the theme still flows through.
const SLOT_FONT_SCALE := 0.5

@onready var saved_games_container = %SavedGameContainer
@onready var saved_games_list: VBoxContainer = %SavedGameContainer/SavedGames
@onready var _new_game_button: Button = $CenterContainer/StartMenu/MarginContainer/VBoxContainer/NewGameButton
@onready var _load_button: Button = $CenterContainer/StartMenu/MarginContainer/VBoxContainer/LoadButton
@onready var _exit_game_button: Button = %ExitButton

# Shared by every slot row so exactly one can be selected at a time.
var _slot_group := ButtonGroup.new()


func _ready():
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_load_button.pressed.connect(_on_load_pressed)
	_slot_group.pressed.connect(_on_slot_selected)
	_exit_game_button.pressed.connect(_on_exit_game_button_pressed)

	if not Engine.is_editor_hint():
		_populate_saved_games()

	# Nothing is selected on entry, so neither action has a target yet.
	_load_button.disabled = true
	_new_game_button.disabled = true


func _populate_saved_games() -> void:
	# Clear the placeholder rows authored in the scene.
	for child in saved_games_list.get_children():
		child.queue_free()

	# Resolved from this Control's theme context, which is what the rows would
	# otherwise inherit. Falls back to the Godot default if the theme is missing
	# an entry, so a lookup miss can't render the rows at size zero.
	var base_font_size := get_theme_font_size("font_size", "Button")
	if base_font_size <= 0:
		base_font_size = 16
	var slot_font_size := int(base_font_size * SLOT_FONT_SCALE)

	for slot in SaveCtl.list_slots():
		var row := Button.new()
		row.text = slot.display_name
		row.toggle_mode = true
		row.button_group = _slot_group
		row.add_theme_font_size_override("font_size", slot_font_size)
		# Slot number and occupancy ride along with the row, so selection needs
		# no index bookkeeping against the list.
		row.set_meta("slot_index", slot.index)
		row.set_meta("slot_occupied", slot.exists)
		saved_games_list.add_child(row)


## An empty slot is somewhere to start a new game; an occupied one is something
## to load. Only ever one of the two, so a new game can't land on a save.
func _on_slot_selected(button: BaseButton) -> void:
	var occupied: bool = button.get_meta("slot_occupied")
	_load_button.disabled = not occupied
	_new_game_button.disabled = occupied


func _on_new_game_pressed() -> void:
	var selected := _slot_group.get_pressed_button()
	if selected == null:
		return

	var slot_index: int = selected.get_meta("slot_index")
	logging.log("new game in slot %d" % slot_index)
	SaveCtl.select_slot(slot_index)
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_load_pressed() -> void:
	var selected := _slot_group.get_pressed_button()
	if selected == null:
		return

	var slot_index: int = selected.get_meta("slot_index")
	logging.log("loading slot %d" % slot_index)
	SaveCtl.select_slot(slot_index)
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
