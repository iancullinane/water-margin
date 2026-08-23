## Child nodes are used as containers for entity, also handles switching
## the player and loading the player party if it is missing
extends Node
## This is the entity controller, it manages loading and manipulating entities, think of it like
## the hands of a marionette
class_name EntityCtl

enum EntityType {
	PARTY,
	ENEMY,
	NPC
}

var current_player: IEntity
@export var _current_party_member_idx: int = 0
## Movement intent while a direction key is held. Consumed on arrival so a
## held key chains cell-to-cell inside the Mover's physics tick; the Animator
## (which samples mover.is_moving right after the Mover) then never sees an
## idle gap that would restart the walk animation.
var held_direction: Vector2 = Vector2.ZERO
## Seconds a direction must stay pressed before a tap becomes continuous
## walking. A cell takes CELL_SIZE / move_speed seconds — shorter than a
## natural tap — so keep this just under the traversal time: taps stay
## single-step and a real hold starts chaining before the first cell ends.
@export var hold_to_walk_delay: float = 0.14

var _intent_dir: Vector2 = Vector2.ZERO
var _intent_held_time: float = 0.0
# The map mount point, injected by the composition root (game.gd) so this
# controller can validate moves without reaching up/across the scene tree.
var map_ctl: MapCtl
# The three kinds of entities are stored as children
# of parent nodes
# TODO: Rebuild entity management with groups
#   Entities are currently children of a node and we use `get_children` to extract them. This likely makes more sense as one node and each set of entites should be a group.
@onready var party: Node2D = $Party
@onready var enemies: Node2D = $Enemies
@onready var npcs: Node2D = $NPCs


func _ready() -> void:
	SignalBus.current_player_moved.connect(_on_current_player_moved)

## Called by InputCtl every frame with the currently pressed direction (ZERO
## when none). A fresh press or direction change steps once immediately;
## holding past hold_to_walk_delay walks continuously via arrival chaining.
func update_move_intent(dir: Vector2, delta: float) -> void:
	var previous_dir := _intent_dir
	_intent_dir = dir
	var fresh := dir != previous_dir
	_intent_held_time = 0.0 if fresh else _intent_held_time + delta

	var walking := not fresh and dir != Vector2.ZERO \
			and _intent_held_time >= hold_to_walk_delay
	held_direction = dir if walking else Vector2.ZERO

	# `walking` retries every frame as a fallback in case an arrival chain was
	# rejected (e.g. a wall) and the path later clears; rejected while a move
	# is already in flight, so it never double-steps.
	if dir != Vector2.ZERO and (fresh or walking):
		try_move(current_player, dir)

## Fires synchronously from the Mover on arrival — before the Animator's tick.
func _on_current_player_moved(entity: Node2D) -> void:
	if entity == current_player and held_direction != Vector2.ZERO:
		try_move(current_player, held_direction)


func get_current_player() -> IEntity:
	return current_player

# func add_entity(type: EntityType, entity: IEntity) -> void:
# 	var container := _get_container(type)
# 	if container:
# 		container.add_child(entity)

# func _add_party_member(entity: IEntity) -> void:
# 	var party_container = _get_container(EntityType.PARTY)
# 	if party_container.get_child_count() == 0:
# 		current_player = entity

# 	party_container.add_child(entity)

func get_entity_group(type: EntityType) -> Array[IEntity]:
	var result: Array[IEntity] = []
	var container := _get_container(type)
	if container:
		for child in container.get_children():
			if child is IEntity:
				result.append(child)
	return result

## Depending on the type, return the node which holds
## entities of that type
func _get_container(type: EntityType) -> Node2D:
	match type:
		EntityType.PARTY:
			return party
		EntityType.ENEMY:
			return enemies
		EntityType.NPC:
			return npcs
	return null

func get_all_entities() -> Array[IEntity]:
	var result: Array[IEntity] = []
	for entity in get_entity_group(EntityType.PARTY):
		result.append(entity)
	for entity in get_entity_group(EntityType.ENEMY):
		result.append(entity)
	for entity in get_entity_group(EntityType.NPC):
		result.append(entity)
	return result

func get_entity_by_index(type: EntityType, index: int) -> IEntity:
	var group := get_entity_group(type)
	if index >= 0 and index < group.size():
		return group[index]
	return null

# func get_entity_by_name(entity_name: String) -> Node2D:
# 	for entity in get_entity_group(EntityType.PARTY):
# 		if entity.stats and entity.stats.name == entity_name:
# 			return entity
# 		elif entity.name == entity_name:
# 			return entity
# 	return null


func next_player():
	var player_group := get_entity_group(EntityType.PARTY)
	if player_group.size() == 0:
		return

	_current_party_member_idx = posmod(_current_party_member_idx + 1, player_group.size())
	current_player = get_entity_by_index(EntityType.PARTY, _current_party_member_idx)
	if current_player:
		SignalBus.current_player_changed.emit(current_player)

func previous_player():
	var player_group := get_entity_group(EntityType.PARTY)
	if player_group.size() == 0:
		return

	_current_party_member_idx = posmod(_current_party_member_idx - 1, player_group.size())
	current_player = get_entity_by_index(EntityType.PARTY, _current_party_member_idx)
	if current_player:
		SignalBus.current_player_changed.emit(current_player)


# Control methods
func set_current_player(entity: IEntity):
	var group := get_entity_group(EntityType.PARTY)
	if entity and entity in group:
		# The controller owns "who is selected" — entities stay self-contained
		# and learn about it via the signal.
		current_player = entity
		# Keep Tab/Shift+Tab cycling from the newly selected member
		_current_party_member_idx = group.find(entity)
		# Emit signal for camera tracking
		SignalBus.current_player_changed.emit(entity)

func set_current_player_by_index(index: int):
	var entity = get_entity_by_index(EntityType.PARTY, index)
	if entity:
		set_current_player(entity)

func move_current_player(dir: Vector2):
	try_move(current_player, dir)

## try_move validates a grid step for `entity` against terrain and other
## entities, then commands the entity to step. World knowledge lives here in
## the controller ("the hands of the marionette") so entities stay
## self-contained. Reusable for player and NPC movement alike.
func try_move(entity: IEntity, dir: Vector2) -> bool:
	if entity == null:
		return false
	var target: Vector2 = entity.position + dir * GameConstants.CELL_SIZE
	if _is_tile_blocked(target):
		return false
	if _is_cell_occupied(target, entity):
		return false
	return entity.step(dir)

func _is_tile_blocked(target_pos: Vector2) -> bool:
	if map_ctl == null:
		return false
	var game_map := map_ctl.get_current_map()
	if game_map == null:
		return false
	var tile_coords := game_map.get_tile_from_global(target_pos)
	return game_map.get_movement_cost(tile_coords) > 0

func _is_cell_occupied(target_pos: Vector2, mover: IEntity) -> bool:
	for e in get_all_entities():
		if e != mover and e.position.distance_to(target_pos) < 1.0:
			return true
	return false



func spawn_party(last_selected_player: String, entity_save: Array[ObjectData]):
	for e in entity_save:
		var scene = load(e.scene_path) as PackedScene
		var restored_node = scene.instantiate()

		party.add_child(restored_node)
		restored_node.on_load_game(e)
		if last_selected_player == restored_node.name:
			set_current_player(restored_node)

	# Saves written before last_selected_player existed (or a roster change)
	# leave nothing selected — fall back to the first party member so the
	# player is never left with no one to control.
	if current_player == null:
		set_current_player(get_entity_by_index(EntityType.PARTY, 0))

func spawn_enemies(entity_save: Array[ObjectData]):
	for e in entity_save:
		var scene = load(e.scene_path) as PackedScene
		var restored_node = scene.instantiate()

		enemies.add_child(restored_node)
		restored_node.on_load_game(e)
