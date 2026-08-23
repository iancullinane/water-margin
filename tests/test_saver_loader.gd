extends GutTest

## Tests for the load side of SaverLoader — specifically that a new game reads
## the committed base save template instead of special-casing an empty slot.
##
## load_game() touches SaveCtl but not the Game node, so we can exercise it on
## a bare SaverLoader. SaveCtl is the real autoload, so we point it at a scratch
## directory for the duration and restore it afterwards.

const TEST_DIR := "user://test_saverloader/"

var saver_loader: SaverLoader
var _real_save_dir: String
var _real_slot_path: String


func before_each() -> void:
	_real_save_dir = SaveCtl.save_dir
	_real_slot_path = SaveCtl.current_slot_path
	_clear_test_dir()
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	SaveCtl.save_dir = TEST_DIR
	SaveCtl.current_slot_path = ""

	saver_loader = SaverLoader.new()
	add_child_autofree(saver_loader)


func after_each() -> void:
	SaveCtl.save_dir = _real_save_dir
	SaveCtl.current_slot_path = _real_slot_path
	_clear_test_dir()


func _clear_test_dir() -> void:
	var dir := DirAccess.open(TEST_DIR)
	if dir == null:
		return
	for file_name in dir.get_files():
		dir.remove(file_name)
	DirAccess.remove_absolute(TEST_DIR)


# --- the base save template -------------------------------------------------

func test_new_game_template_exists() -> void:
	assert_true(ResourceLoader.exists(SaveCtl.NEW_GAME_TEMPLATE),
		"the base save game must be committed to the project")


func test_new_game_template_defines_a_party() -> void:
	var template := load(SaveCtl.NEW_GAME_TEMPLATE) as SavedGame
	assert_not_null(template, "template should load as a SavedGame")
	assert_gt(template.party_data.size(), 0,
		"a new game must start with at least one party member")


func test_new_game_template_entity_scenes_resolve() -> void:
	# A typo'd scene_path would only surface as a crash on New Game, so pin it.
	var template := load(SaveCtl.NEW_GAME_TEMPLATE) as SavedGame
	for entry in template.party_data + template.enemy_data:
		assert_true(ResourceLoader.exists(entry.scene_path),
			"template references a missing scene: %s" % entry.scene_path)


func test_new_game_template_selects_a_starting_player() -> void:
	var template := load(SaveCtl.NEW_GAME_TEMPLATE) as SavedGame
	assert_ne(template.last_selected_player, "",
		"template should name the party member the player starts controlling")


# --- load_game --------------------------------------------------------------

func test_load_game_falls_back_to_the_template_for_a_new_game() -> void:
	# No slot selected and none on disk: this is New Game.
	var loaded := saver_loader.load_game()
	assert_not_null(loaded, "a new game must still produce a world to spawn")
	assert_gt(loaded.party_data.size(), 0, "new game should spawn the base party")


func test_load_game_falls_back_when_the_slot_file_is_missing() -> void:
	# An empty slot picked for a new game — the path exists, the file does not.
	SaveCtl.select_slot(3)
	var loaded := saver_loader.load_game()
	assert_not_null(loaded, "an empty slot should fall back to the template")


func test_load_game_reads_the_active_slot_when_it_exists() -> void:
	SaveCtl.select_slot(3)
	var stored := SavedGame.new()
	stored.name = "a_real_save"
	ResourceSaver.save(stored, SaveCtl.get_active_slot())

	var loaded := saver_loader.load_game()
	assert_eq(loaded.name, "a_real_save",
		"an existing slot must win over the template")


# --- the template must never be a write target ------------------------------

func test_template_lives_outside_the_writable_save_dir() -> void:
	# Saving always targets SaveCtl.get_active_slot(), which is built from
	# save_dir. Keeping the template in res:// means no save path can reach it.
	assert_true(SaveCtl.NEW_GAME_TEMPLATE.begins_with("res://"),
		"template must live in the project, not user data")
	assert_true(_real_save_dir.begins_with("user://"),
		"slots must live in user data, not the project")


func test_selected_slots_never_point_at_the_template() -> void:
	for index in range(1, SaveCtl.SLOT_COUNT + 1):
		SaveCtl.select_slot(index)
		assert_ne(SaveCtl.get_active_slot(), SaveCtl.NEW_GAME_TEMPLATE,
			"no slot may resolve to the template path")
