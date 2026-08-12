extends GutTest

## Unit tests for Mover — the grid-step component that glides an entity to its
## target cell. Movement runs through CharacterBody2D move_and_slide(), which
## only integrates motion inside a real engine physics step — so these tests
## await physics frames instead of calling _physics_process by hand.

var CELL: int = GameConstants.CELL_SIZE

const MoverScript := preload("res://scripts/entities/mover.gd")

# An IEntity host carrying a *real* Mover. NameLabel/AnimationPlayer are empty
# placeholders so IEntity's @onready lookups don't push "Node not found"
# engine errors (see FakeEntity in test_entity_ctl.gd).
class MoverHost extends IEntity:
	func _init() -> void:
		for child_name in ["NameLabel", "AnimationPlayer"]:
			var stub := Node2D.new()
			stub.name = child_name
			add_child(stub)
		var real_mover := MoverScript.new()
		real_mover.name = "Mover"
		add_child(real_mover)


var host: MoverHost
var target_mover: Node


func before_each() -> void:
	host = MoverHost.new()
	# In the tree so @onready resolves, _ready snaps to grid, and the engine
	# drives the Mover's _physics_process.
	add_child_autofree(host)
	host.position = Vector2.ZERO
	target_mover = host.mover


# Await physics frames until the move completes; bounded so a regression
# can't hang the run. A 16px cell at 150px/s needs ~7 frames at 60fps.
func _wait_until_arrived(max_frames := 60) -> void:
	for i in range(max_frames):
		if not target_mover.is_moving:
			return
		await get_tree().physics_frame


func test_step_moves_one_cell() -> void:
	assert_true(host.step(Vector2.RIGHT), "step onto a clear cell should start a move")
	await _wait_until_arrived()
	assert_false(target_mover.is_moving, "move should complete within the frame budget")
	assert_eq(host.position, Vector2(CELL, 0), "entity should snap exactly one cell right")


func test_arrival_zeroes_velocity_and_emits_signal() -> void:
	watch_signals(SignalBus)
	host.step(Vector2.DOWN)
	await _wait_until_arrived()
	assert_eq(host.velocity, Vector2.ZERO, "velocity should be cleared on arrival")
	assert_signal_emitted_with_parameters(SignalBus, "current_player_moved", [host])


func test_step_rejected_while_moving() -> void:
	host.step(Vector2.RIGHT)
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_true(target_mover.is_moving, "two physics ticks should not finish a full cell")
	assert_false(host.step(Vector2.UP), "a second step mid-move should be rejected")
	assert_eq(target_mover.target_position, Vector2(CELL, 0), "target should be unchanged by the rejected step")
