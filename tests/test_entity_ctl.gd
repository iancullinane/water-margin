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
	ctl.add_party_member(e)
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
