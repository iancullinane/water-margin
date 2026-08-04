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
	saved_game.last_selected_player = game.entity_ctl.get_current_player().name

	var saved_data:Array[SavedData] = []
	for e in game.entity_ctl.get_all_entities():
		e.on_save_game(saved_data)

	saved_game.saved_data = saved_data
	DirAccess.make_dir_recursive_absolute("user://savegames")
	ResourceSaver.save(saved_game, "user://savegames/savegame.tres")


func load_game() -> SavedGame:
	var saved_game:SavedGame = load("user://savegames/savegame.tres") as SavedGame

	# logging.warn("%v" % saved_game.player_list.size())
	return saved_game
