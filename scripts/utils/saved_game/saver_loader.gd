extends Node
##  Save and Load game data generically.
class_name SaverLoader


# Nested under Game/Utils, so use owner (the scene root) rather than get_parent()
@onready var game: Game = owner as Game


# ls -la ~/Library/Application\ Support/Godot/app_userdata/Water\ Margin/savegames

func _ready():
	SignalBus.save_game.connect(save_game)

func save_game():
	logging.log("Initiating save game")
	var saved_game: SavedGame = SavedGame.new()
	var current := game.entity_ctl.get_current_player()
	if current:
		saved_game.last_selected_player = current.name

	var saved_data:Array[SavedData] = []
	for e in game.entity_ctl.get_all_entities():
		e.on_save_game(saved_data)

	saved_game.saved_data = saved_data

	# Save back to the slot we loaded from, so a session keeps overwriting its
	# own file rather than scattering new ones. A game started without going
	# through the start screen has no slot yet, so mint one on first save.
	var slot_path := SaveCtl.get_active_slot()
	if slot_path == "":
		slot_path = SaveCtl.new_slot()

	SaveCtl.ensure_save_dir()
	ResourceSaver.save(saved_game, slot_path)


## load_game reads the active slot. Returns null when there is no slot to
## read — a new game — so callers must handle that before touching the result.
func load_game() -> SavedGame:
	var slot_path := SaveCtl.get_active_slot()
	if slot_path == "" or not FileAccess.file_exists(slot_path):
		return null

	return load(slot_path) as SavedGame
