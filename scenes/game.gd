extends Node2D


@onready var entity_ctl = $EntityCtl
@onready var camera_ctl: Camera2D = $CameraCtl



@export_group("Debug flags")
@export var height: int;
@export var width: int;


# var grid: Array
var _current_party_index: int = 0


func _ready():
	# Connect signals for camera movement
	SignalBus.current_player_changed.connect(_on_current_player_changed)
	SignalBus.current_player_moved.connect(_on_current_player_moved)
	
	
	# Set initial player and snap camera to position
	entity_ctl.set_current_player_by_index(0)
	var current: Entity = entity_ctl.get_current_player()
	if current:
		camera_ctl.position_smoothing_enabled = false
		camera_ctl.position = current.position
		camera_ctl.reset_smoothing()
		camera_ctl.position_smoothing_enabled = true

func _unhandled_input(_event):
	if entity_ctl.get_entity_count() == 0:
		return
	# Prioritize previous when both fire (e.g., Shift+Tab)
	if Input.is_action_just_pressed("previous_character"):
		_select_player(_current_party_index - 1)
	elif Input.is_action_just_pressed("next_character"):
		_select_player(_current_party_index + 1)

func _select_player(new_index: int) -> void:
	if entity_ctl.get_entity_count() == 0:
		return
	var wrapped_index := posmod(new_index, entity_ctl.get_entity_count())
	# Turn off previous only if changing index
	if wrapped_index != _current_party_index:
		var previous_player: Entity = entity_ctl.get_entity_by_index(_current_party_index)
		if previous_player:
			previous_player.current_player = false
	# Turn on new
	_current_party_index = wrapped_index
	var new_player: Entity = entity_ctl.get_entity_by_index(_current_party_index)
	if new_player:
		entity_ctl.set_current_player(new_player)
		# Update focus follower, if present
		var focus_node = get_node_or_null("GameFocus")
		if focus_node:
			focus_node.player = new_player
		
		print("Current player is %s" % new_player.name)




# Signal handlers for camera movement
func _on_current_player_changed(entity: Entity):
	if entity:
		camera_ctl.position = entity.position

func _on_current_player_moved(entity: Entity):
	if entity:
		camera_ctl.position = entity.position

# func _on_hovered(event_data: UiEventData):
# 	if event_data:
# 		camera_ctl.position = event_data.coordinates