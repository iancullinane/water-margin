## Owns everything about save slots: where they live on disk, how they are
## listed, and which one the running game reads from and writes back to.
## Registered as the SaveCtl autoload.
##
## The start screen selects a slot here; SaverLoader reads it. Neither knows
## about the other, and change_scene_to_file needs no arguments.
extends Node

# Not a const so tests can point at a scratch directory instead of the
# player's real savegames.
var save_dir := "user://savegames/"

## The slot the game loads from and saves back to. Empty until the start
## screen selects one or get_active_slot() resolves the fallback.
var current_slot_path := ""

const _SLOT_PREFIX := "savegame_"

## The world as it should exist when a player starts a new game, authored as a
## normal SavedGame resource. Living in res:// keeps it out of reach of every
## write path, which only ever targets a slot under save_dir.
const NEW_GAME_TEMPLATE := "res://data/saves/new_game.tres"


## list_slots returns every save slot, newest first, as dictionaries of
## {path, modified, display_name}. Slots are listed from directory metadata
## alone — no SavedGame resource is deserialized just to draw a menu row.
func list_slots() -> Array:
	var slots := []
	var dir := DirAccess.open(save_dir)
	if dir == null:
		return slots

	for file_name in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var path: String = save_dir.path_join(file_name)
		var modified := FileAccess.get_modified_time(path)
		slots.append({
			"path": path,
			"modified": modified,
			"display_name": Time.get_datetime_string_from_unix_time(modified).replace("T", " "),
		})

	slots.sort_custom(_newest_first)
	return slots


# Slots minted in the same second share a modified time, so fall back to
# name order to keep listing deterministic.
func _newest_first(a: Dictionary, b: Dictionary) -> bool:
	if a.modified == b.modified:
		return a.path > b.path
	return a.modified > b.modified


## new_slot reserves a path for a fresh game and selects it. No file is
## written — the slot appears in list_slots() only once the game first saves,
## so starting a new game and quitting leaves no empty slot behind.
func new_slot() -> String:
	var stamp := int(Time.get_unix_time_from_system())
	var path := _slot_path(stamp)
	# Two new games in the same second would otherwise collide.
	while FileAccess.file_exists(path):
		stamp += 1
		path = _slot_path(stamp)
	current_slot_path = path
	return path


func _slot_path(stamp: int) -> String:
	return save_dir.path_join("%s%d.tres" % [_SLOT_PREFIX, stamp])


## select_slot points the session at an existing slot.
func select_slot(path: String) -> void:
	current_slot_path = path


## get_active_slot resolves which slot the game should use. With nothing
## explicitly selected — running game.tscn directly with F5, bypassing the
## start screen — it falls back to the most recent slot so the dev loop keeps
## resuming where it left off. The resolved path sticks, so a later save
## overwrites that slot rather than minting a second one.
## Returns "" when no slot has been selected and none exist: a new game.
func get_active_slot() -> String:
	if current_slot_path == "":
		var slots := list_slots()
		if not slots.is_empty():
			current_slot_path = slots[0].path
	return current_slot_path


## ensure_save_dir creates the save directory if it is missing. Callers that
## are about to write a slot should call this first.
func ensure_save_dir() -> void:
	DirAccess.make_dir_recursive_absolute(save_dir)
