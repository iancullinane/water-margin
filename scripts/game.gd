@tool
extends Node2D

# @export var height: int;
# @export var width: int;

@export_group("Debug flags")
# -------------------------------

const map001 = preload("res://scenes/map/map_001.tscn")

# These manage the state file itself
const PartyStateRsc = preload("res://data/saves/PartyState.gd")
const PartyMemberStateRsc = preload("res://data/saves/PartyMemberState.gd")
# This is the file that keeps track of where the
# player is persistently from game to game
const STATE_PATH := "user://party_state.tres"

# controllers
# -----------
@onready var entity_ctl: EntityCtl = $EntityCtl
@onready var map_ctl: MapCtl = $MapCtl
@onready var camera: Camera2D = $Camera
@onready var level_loader = $LevelLoader


# -----------------------------------------------------------

func get_map_ctl() -> MapCtl:
	return map_ctl

func get_camera_ctl() -> Camera2D:
	return camera

func get_level_loader():
	return level_loader
# ------------------------------------------------------------

# This is V2 of the _ready function, most notably we are using
# lebvel_loader which "knows" how to find the map holder
func _ready():

	# In editor, only ensure the map is visible; skip runtime wiring
	if Engine.is_editor_hint():
		level_loader.ensure_map_loaded()
		return
	# Runtime: initialize systems
	level_loader.ensure_map_loaded()
	entity_ctl.spawn_party_if_missing()
	_load_party_state()
	_apply_camera_limits()

	# make sure the camera is set to something
	# meaningful. which is the current player
	_snap_camera_to_current_at_start()

	# the game is now running on a particular map, see
	# editor for Scenetree, and controllers in
	#
	# 	components/ctl
	#
	# Player party is not in idle editor, as the party
	# is added after the party is added.
	#
	# Project provides the following globals:
		# SignalBus
		# GameConstants


func _exit_tree():
	if Engine.is_editor_hint():
		return
	_save_party_state()

func _spawn_party_if_missing() -> void:
	if entity_ctl == null:
		push_error("EntityCtl is null in _spawn_party_if_missing")
		return
	entity_ctl.spawn_party_if_missing()



func _apply_camera_limits() -> void:
	var current_map: GameMap = level_loader.get_current_map()
	if not current_map:
		return
	var bounds := current_map.get_map_pixel_rect()
	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)
	print("[Game] Camera limits set — L:%d T:%d R:%d B:%d (bounds: %s)" % [camera.limit_left, camera.limit_top, camera.limit_right, camera.limit_bottom, bounds])


func _snap_camera_to_current_at_start() -> void:
	if camera == null:
		return
	var current: Node2D = entity_ctl.current_player
	if current:
		camera.position_smoothing_enabled = false
		camera.position = current.position
		camera.reset_smoothing()
		camera.position_smoothing_enabled = true
		SignalBus.current_player_moved.emit(current)

## _load_party_state gets the user state resource from user
## storage.
func _load_party_state() -> void:
	if not ResourceLoader.exists(STATE_PATH):
		return
	var state := ResourceLoader.load(STATE_PATH) as PartyState
	if state == null:
		return
	for m in state.members:
		var e = entity_ctl.get_entity_by_name(m.name)
		if e:
			e.position = m.position
			e.snap_to_grid()

## _save_party_state saves the user state resource from user
## storage.
func _save_party_state() -> void:
	var state := PartyState.new()
	for e in entity_ctl.get_all_entities():
		var m := PartyMemberState.new()
		m.name = e.name
		m.position = e.position
		state.members.append(m)
	ResourceSaver.save(state, STATE_PATH)
