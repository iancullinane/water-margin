extends Node
class_name EntityCtl

enum EntityType {
	PARTY,
	ENEMY,
	NPC
}

var current_player: IEntity

# The three kinds of entities are stored as children
# of parent nodes
@onready var party: Node2D = $Party
@onready var enemies: Node2D = $Enemies
@onready var npcs: Node2D = $NPCs



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

# func set_current_player_by_name(entity_name: String):
# 	var entity = get_entity_by_name(entity_name)
# 	if entity:
# 		set_current_player(entity)

func get_current_player() -> IEntity:
	for entity in get_entity_group(EntityType.PARTY):
		if entity.current_player:
			return entity
	return null




# # Manipulation methods
# func move_entity(entity: Entity, direction: String):
#	 if entity and entity in entities:
#		 entity._on_move(direction)

# func move_entity_by_index(index: int, direction: String):
#	 var entity = get_entity_by_index(index)
#	 if entity:
#		 move_entity(entity, direction)

# func move_current_player(direction: String):
#	 var current = get_current_player()
#	 if current:
#		 move_entity(current, direction)

# func set_entity_position(entity: Entity, new_position: Vector2):
#	 if entity and entity in entities:
#		 entity.position = new_position

# func set_entity_position_by_index(index: int, new_position: Vector2):
#	 var entity = get_entity_by_index(index)
#	 if entity:
#		 set_entity_position(entity, new_position)
