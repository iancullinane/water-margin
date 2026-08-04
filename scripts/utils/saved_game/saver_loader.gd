extends Node
##  Save and Load game data generically.
class_name SaverLoader

# ls -la ~/Library/Application\ Support/Godot/app_userdata/Water\ Margin

func save_game():
	logging.log("Initiating save game")
	var saved_game: SavedGame = SavedGame.new()

	saved_game.player_list.append("Llew_v2")

	DirAccess.make_dir_recursive_absolute("user://savegames")
	ResourceSaver.save(saved_game, "user://savegames/savegame.tres")


func load_game():
	var saved_game:SavedGame = load("user://savegames/savegame.tres") as SavedGame

	logging.warn("%v" % saved_game.player_list.size())
