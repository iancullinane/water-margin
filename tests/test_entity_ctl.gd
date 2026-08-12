extends GutTest

## Unit tests for EntityCtl.try_move — the grid-step validation that lives in
## the controller ("the hands of the marionette"). We use lightweight doubles
## so we never have to load the full entity scenes or a real TileMap.

const CELL := 16

# A stand-in entity that records the step it was told to take instead of
# delegating to a real Mover. step() is the only IEntity surface try_move uses.
class FakeEntity extends IEntity:
	var stepped_dir = null
	var step_return := true

	# IEntity resolves NameLabel/AnimationPlayer/Mover via @onready. Supply empty
	# placeholders so those lookups don't push "Node not found" engine errors
	# (which GUT would otherwise count as test failures).
	func _init() -> void:
		for child_name in ["NameLabel", "AnimationPlayer", "Mover"]:
			var stub := Node2D.new()
			stub.name = child_name
			add_child(stub)

	func step(dir: Vector2) -> bool:
		stepped_dir = dir
		return step_return

# A map that reports a fixed movement cost so we can simulate blocked terrain
# without a TileSet. Never added to the tree, so _ready never runs.
class FakeMap extends GameMap:
	var blocked := false

	func get_tile_from_global(_global: Vector2) -> Vector2i:
		return Vector2i.ZERO

	func get_movement_cost(_tile_coords: Vector2i) -> int:
		return 1 if blocked else 0

# A map mount that hands back our FakeMap without parenting it into the tree.
class FakeMapCtl extends MapCtl:
	var fake_map: GameMap

	func get_current_map() -> GameMap:
		return fake_map


var ctl: EntityCtl


func before_each() -> void:
	ctl = EntityCtl.new()
	# EntityCtl resolves its containers via @onready, so they must exist as
	# named children before it enters the tree.
	for container_name in ["Party", "Enemies", "NPCs"]:
		var container := Node2D.new()
		container.name = container_name
		ctl.add_child(container)
	add_child_autofree(ctl)


func _make_entity(pos: Vector2) -> FakeEntity:
	var e := FakeEntity.new()
	# Parented straight into the party container — try_move takes its target
	# explicitly, so these tests never need a selected player.
	ctl.party.add_child(e)
	e.position = pos
	return e


func test_null_entity_returns_false() -> void:
	assert_false(ctl.try_move(null, Vector2.RIGHT))


func test_move_into_clear_cell_steps_and_returns_true() -> void:
	# No map_ctl assigned, so terrain is never blocking; cell is empty.
	var e := _make_entity(Vector2.ZERO)
	assert_true(ctl.try_move(e, Vector2.RIGHT), "should succeed onto a clear cell")
	assert_eq(e.stepped_dir, Vector2.RIGHT, "entity should be stepped in the move direction")


func test_move_into_occupied_cell_returns_false() -> void:
	var mover := _make_entity(Vector2.ZERO)
	# Block the cell directly to the right.
	_make_entity(Vector2(CELL, 0))
	assert_false(ctl.try_move(mover, Vector2.RIGHT), "should fail into an occupied cell")
	assert_null(mover.stepped_dir, "blocked mover should not be stepped")


func test_move_into_blocked_tile_returns_false() -> void:
	var map_ctl := FakeMapCtl.new()
	var map := FakeMap.new()
	map.blocked = true
	map_ctl.fake_map = map
	ctl.map_ctl = map_ctl

	var e := _make_entity(Vector2.ZERO)
	assert_false(ctl.try_move(e, Vector2.RIGHT), "should fail into blocked terrain")
	assert_null(e.stepped_dir, "blocked mover should not be stepped")

	map.free()
	map_ctl.free()


# ---- Held-direction chaining ----
#
# While a movement key is held, arrival at a cell must chain straight into the
# next step *synchronously* (inside the current_player_moved emit, which fires
# during the Mover's physics tick). Otherwise the Animator — which samples
# mover.is_moving every physics tick — sees a one-tick idle gap at every cell
# boundary and restarts the walk animation.

const MoverScript := preload("res://scripts/entities/mover.gd")

# An IEntity carrying a *real* Mover, for driving actual grid moves in-tree.
class ChainHost extends IEntity:
	func _init() -> void:
		for child_name in ["NameLabel", "AnimationPlayer"]:
			var stub := Node2D.new()
			stub.name = child_name
			add_child(stub)
		var real_mover := MoverScript.new()
		real_mover.name = "Mover"
		add_child(real_mover)

# Sits after the Mover in the entity, exactly like the Animator, and records
# what is_moving looks like from there on every physics tick.
class AnimatorProbe extends Node:
	var mover: Node
	var samples: Array[bool] = []

	func _physics_process(_delta: float) -> void:
		samples.append(mover.is_moving)


func test_arrival_with_held_direction_chains_next_step() -> void:
	var e := _make_entity(Vector2.ZERO)
	ctl.set_current_player(e)
	ctl.held_direction = Vector2.RIGHT
	SignalBus.current_player_moved.emit(e)
	assert_eq(e.stepped_dir, Vector2.RIGHT, "arrival should chain a step in the held direction")


func test_arrival_without_held_direction_does_not_step() -> void:
	var e := _make_entity(Vector2.ZERO)
	ctl.set_current_player(e)
	SignalBus.current_player_moved.emit(e)
	assert_null(e.stepped_dir, "no held direction means no chained step")


func test_arrival_of_non_current_entity_does_not_chain() -> void:
	var e := _make_entity(Vector2.ZERO)
	var other := _make_entity(Vector2(CELL * 3, 0))
	ctl.set_current_player(e)
	ctl.held_direction = Vector2.RIGHT
	SignalBus.current_player_moved.emit(other)
	assert_null(other.stepped_dir, "a non-current entity's arrival should not chain")
	assert_null(e.stepped_dir, "the current player should not step off another entity's arrival")


func test_held_direction_chains_without_idle_gap() -> void:
	var e := ChainHost.new()
	ctl.party.add_child(e)
	e.position = Vector2.ZERO
	var probe := AnimatorProbe.new()
	e.add_child(probe)
	probe.mover = e.mover
	ctl.set_current_player(e)

	ctl.held_direction = Vector2.RIGHT
	ctl.move_current_player(Vector2.RIGHT)

	# Walk at least two chained cells, then release the "key".
	for i in range(60):
		await get_tree().physics_frame
		if e.position.x >= CELL * 2:
			ctl.held_direction = Vector2.ZERO
			break
	for i in range(30):
		if not e.mover.is_moving:
			break
		await get_tree().physics_frame

	assert_true(e.position.x >= CELL * 2, "should have chained across at least two cells")
	var first: int = probe.samples.find(true)
	var last: int = probe.samples.rfind(true)
	assert_true(first != -1, "probe should have seen the entity moving")
	var flickered := false
	for i in range(first, last + 1):
		if not probe.samples[i]:
			flickered = true
	assert_false(flickered, "is_moving must never read false between chained steps")
