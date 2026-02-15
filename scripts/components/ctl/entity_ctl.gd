extends Node
class_name EntityCtl

enum EntityType {
	PARTY,
	ENEMY,
	NPC
}

var current_player: IEntity
@export var _current_party_member_idx: int = 0

# Character scene dictionary
var character_scenes := {
	"Llew_v2": preload("res://scenes/entities/players/llew_v2.tscn"),
	"Elliette_v2": preload("res://scenes/entities/players/elliette_v2.tscn"),
	"Eignh_v2": preload("res://scenes/entities/players/eignh_v2.tscn")
}

# The three kinds of entities are stored as children
# of parent nodes
@onready var party: Node2D = $Party
@onready var enemies: Node2D = $Enemies
@onready var npcs: Node2D = $NPCs

func get_current_player() -> IEntity:
	return current_player

func add_entity(type: EntityType, entity: IEntity) -> void:
	var container := _get_container(type)
	if container:
		container.add_child(entity)

func add_party_member(entity: IEntity) -> void:
	var party_container = _get_container(EntityType.PARTY)
	if party_container.get_child_count() == 0:
		current_player = entity
		entity.current_player = true

	party_container.add_child(entity)

func get_entity_group(type: EntityType) -> Array[IEntity]:
	var result: Array[IEntity] = []
	var container := _get_container(type)
	if container:
		for child in container.get_children():
			if child is IEntity:
				result.append(child)
	return result

func _get_container(type: EntityType) -> Node2D:
	match type:
		EntityType.PARTY:
			return party
		EntityType.ENEMY:
			return enemies
		EntityType.NPC:
			return npcs
	return null

func get_all_entities() -> Array[Node2D]:
	var result: Array[Node2D] = []
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

func get_entity_by_name(entity_name: String) -> Node2D:
	for entity in get_entity_group(EntityType.PARTY):
		if entity.stats and entity.stats.name == entity_name:
			return entity
		elif entity.name == entity_name:
			return entity
	return null


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
		# Disable all others first
		for e in group:
			e.current_player = false
		# Enable the selected one
		entity.current_player = true
		# Emit signal for camera tracking
		SignalBus.current_player_changed.emit(entity)

func set_current_player_by_index(index: int):
	var entity = get_entity_by_index(EntityType.PARTY, index)
	if entity:
		set_current_player(entity)

func move_current_player(dir: Vector2):
	current_player.move(dir)

## spawn_party_if_missing is a method to load a hardcoded set
## of player party member.
func spawn_party_if_missing() -> void:
	if get_entity_by_name("Llew_v2") == null:
		var llew_v2_instance = character_scenes["Llew_v2"].instantiate()
		llew_v2_instance.name = "Llew_v2"
		add_party_member(llew_v2_instance)
		SignalBus.current_player_changed.emit(llew_v2_instance)

	if get_entity_by_name("Elliette_v2") == null:
		var elliette_v2_instance = character_scenes["Elliette_v2"].instantiate()
		elliette_v2_instance.name = "Elliette_v2"
		add_party_member(elliette_v2_instance)

	if get_entity_by_name("Eignh_v2") == null:
		var eignh_v2_instance = character_scenes["Eignh_v2"].instantiate()
		eignh_v2_instance.name = "Eignh_v2"
		add_party_member(eignh_v2_instance)
