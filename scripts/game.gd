@tool
extends Node2D

@export var height: int;
@export var width: int;

@export var _current_party_member_idx: int = 0

@export_group("Debug flags")
# -------------------------------

const map001 = preload("res://scenes/map/map_001.tscn")

# These manage the state file itself
const PartyStateRsc = preload("res://data/saves/PartyState.gd")
const PartyMemberStateRsc = preload("res://data/saves/PartyMemberState.gd")
# This is the file that keeps track of where the
# player is persistently from game to game
const STATE_PATH := "user://party_state.tres"

# These are raw character scenes, this is annoying to hardcode
# but it means they can be edited in the editor which is ideal
const CERAH_SCENE := preload("res://scenes/entities/cerah.tscn")
const EIGNH_SCENE := preload("res://scenes/entities/eignh.tscn")
const LLEWELYN_SCENE := preload("res://scenes/entities/llewelyn.tscn")

const EIGNH_V2_SCENE := preload("res://scenes/entities/eignh_v2.tscn")

# controllers
# -----------
@onready var entity_ctl: EntityCtl = $EntityCtl
@onready var map_ctl: MapCtl = $MapCtl
@onready var camera_ctl: Camera2D = $CameraCtl
@onready var level_loader = $LevelLoader


# -----------------------------------------------------------

const EntityType = EntityCtl.EntityType

func get_map_ctl() -> MapCtl:
	return map_ctl

func get_camera_ctl() -> Camera2D:
	return camera_ctl

func get_level_loader():
	return level_loader
# ------------------------------------------------------------



#
func _connect_signal_bus() -> void:
	if Engine.is_editor_hint():
		return
	if not is_instance_valid(SignalBus):
		return
	if SignalBus.has_signal("current_player_changed"):
		SignalBus.current_player_changed.connect(_on_current_player_changed)
	if SignalBus.has_signal("current_player_moved"):
		SignalBus.current_player_moved.connect(_on_current_player_moved)

# This is V2 of the _ready function, most notably we are using
# lebvel_loader which "knows" how to find the map holder
func _ready():

	# In editor, only ensure the map is visible; skip runtime wiring
	if Engine.is_editor_hint():
		level_loader.ensure_map_loaded()
		return
	# Runtime: connect signals and initialize systems
	call_deferred("_connect_signal_bus")
	level_loader.ensure_map_loaded()
	_spawn_party_if_missing()
	_load_party_state()
	_snap_camera_to_current()




func _exit_tree():
	if Engine.is_editor_hint():
		return
	_save_party_state()

func _unhandled_input(_event):
	if entity_ctl.get_entity_group(EntityType.PARTY).size() == 0:
		return
	# Prioritize previous when both fire (e.g., Shift+Tab)
	if Input.is_action_just_pressed("previous_character"):
		_select_player(_current_party_member_idx - 1)
	elif Input.is_action_just_pressed("next_character"):
		_select_player(_current_party_member_idx + 1)

func _select_player(new_index: int):
	var player_group = entity_ctl.get_entity_group(EntityType.PARTY)
	if player_group.size() == 0:
		return
	var wrapped_index := posmod(new_index, player_group.size())
	# Turn off previous only if changing index
	if wrapped_index != _current_party_member_idx:
		var previous_player: IEntity = entity_ctl.get_entity_by_index(EntityType.PARTY, _current_party_member_idx)
		if previous_player:
			previous_player.current_player = false
	# Turn on new
	_current_party_member_idx = wrapped_index
	var new_player: IEntity = entity_ctl.get_entity_by_index(EntityType.PARTY, _current_party_member_idx)
	if new_player:
		entity_ctl.set_current_player(new_player)
		# Update focus follower, if present
		var focus_node = get_node_or_null("GameFocus")
		if focus_node:
			focus_node.player = new_player

		print("Current player is %s" % new_player.name)




# Signal handlers for camera movement
func _on_current_player_changed(entity: Node2D):
	if entity:
		camera_ctl.position = entity.position

func _on_current_player_moved(entity: Node2D):
	if entity:
		camera_ctl.position = entity.position


func _spawn_party_if_missing() -> void:
	if entity_ctl == null:
		return

	# # Avoid duplicates across editor/runtime reloads
	# if entity_ctl.get_entity_by_name("Cerah") == null:
	# 	var cerah_instance = CERAH_SCENE.instantiate()
	# 	cerah_instance.name = "Cerah"
	# 	entity_ctl.add_child(cerah_instance)

	# if entity_ctl.get_entity_by_name("Eignh") == null:
	# 	var eignh_instance = EIGNH_SCENE.instantiate()
	# 	eignh_instance.name = "Eignh"
	# 	entity_ctl.add_child(eignh_instance)

	# if entity_ctl.get_entity_by_name("Llewelyn") == null:
	# 	var llewelyn_instance = LLEWELYN_SCENE.instantiate()
	# 	llewelyn_instance.name = "Llewelyn"
	# 	entity_ctl.add_child(llewelyn_instance)

	if entity_ctl.get_entity_by_name("Eignh_v2") == null:
		var eignh_v2_instance = EIGNH_V2_SCENE.instantiate()
		eignh_v2_instance.name = "Eignh_v2"
		entity_ctl.add_party_member(eignh_v2_instance)
		entity_ctl.get_current_player()
		# entity_ctl.add_child(eignh_v2_instance)


	# Refresh entity list and set initial player
	# entity_ctl.load_entity_children()
	# if entity_ctl.get_entity_count() > 0:
	# 	# set initial player
	# 	entity_ctl.set_current_player_by_index(0)

func _snap_camera_to_current() -> void:
	if camera_ctl == null:
		return
	var current: Node2D = entity_ctl.current_player
	if current:
		camera_ctl.position_smoothing_enabled = false
		camera_ctl.position = current.position
		camera_ctl.reset_smoothing()
		camera_ctl.position_smoothing_enabled = true


func _load_party_state() -> void:
	if not ResourceLoader.exists(STATE_PATH):
		return
	var state := ResourceLoader.load(STATE_PATH) as PartyState
	if state == null:
		return
	for m in state.members:
		var e: Node2D = entity_ctl.get_entity_by_name(m.name)
		if e:
			e.position = m.position

func _save_party_state() -> void:
	var state := PartyState.new()
	for e in entity_ctl.get_entities():
		var m := PartyMemberState.new()
		m.name = e.name
		m.position = e.position
		state.members.append(m)
	ResourceSaver.save(state, STATE_PATH)
