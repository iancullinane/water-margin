extends Node
##  Save and Load game data generically. It skips to the root "Game" node
## basically as a convenience, even though its an anti-pattern
class_name SaverLoader


# Nested under Game/Utils, so use owner (the scene root) rather than get_parent()
@onready var game: Game = owner as Game


# ls -la ~/Library/Application\ Support/Godot/app_userdata/Water\ Margin/savegames
# zed ~/Library/Application\ Support/Godot/app_userdata/Water\ Margin/savegames/savegame_01.tres

func _ready():
	SignalBus.save_game.connect(save_game)

func save_game():
	logging.log("Initiating save game")
	var saved_game: SavedGame = SavedGame.new()
	var current := game.entity_ctl.get_current_player()
	if current:
		saved_game.last_selected_player = current.name

	var party_data:Array[SavedData] = []
	for e in game.entity_ctl.get_entity_group(EntityCtl.EntityType.PARTY):
		e.on_save_game(party_data)

	saved_game.party_data = party_data

	var enemy_data:Array[SavedData] = []
	for e in game.entity_ctl.get_entity_group(EntityCtl.EntityType.ENEMY):
		e.on_save_game(enemy_data)

	saved_game.enemy_data = enemy_data

	# Save back to the slot we loaded from, so a session keeps overwriting its
	# own file rather than scattering new ones. A game started without going
	# through the start screen has no slot yet, so claim the first free one.
	var slot_path := SaveCtl.get_active_slot()
	if slot_path == "":
		var free_slot := SaveCtl.first_free_slot()
		if free_slot == -1:
			logging.warn("All %d save slots are full, nothing saved" % SaveCtl.SLOT_COUNT)
			return
		SaveCtl.select_slot(free_slot)
		slot_path = SaveCtl.get_active_slot()

	SaveCtl.ensure_save_dir()
	ResourceSaver.save(saved_game, slot_path)


## load_game reads the active slot, falling back to the base save game when
## there is nothing to read — a new game is just the template world loaded
## through the ordinary path, so callers never special-case it.
func load_game() -> SavedGame:
	var slot_path := SaveCtl.get_active_slot()
	if slot_path == "" or not FileAccess.file_exists(slot_path):
		logging.log("No save slot to read, starting from the base save game")
		return load(SaveCtl.NEW_GAME_TEMPLATE) as SavedGame

	return load(slot_path) as SavedGame
