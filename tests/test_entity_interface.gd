extends GutTest

## Unit tests for IEntity scene-independent behavior. The collision shape is
## authored in entity_2.tscn with a baked size, but the source of truth is
## GameConstants.CELL_SIZE — _ready must re-derive the shape from it so the
## scene can never drift out of sync with the grid.

var CELL: int = GameConstants.CELL_SIZE


# An IEntity double with a real CollisionShape2D so we can observe _ready
# sizing it. Other @onready children are empty placeholders (see FakeEntity
# in test_entity_ctl.gd).
class ShapedHost extends IEntity:
	func _init() -> void:
		for child_name in ["NameLabel", "AnimationPlayer", "Mover"]:
			var stub := Node2D.new()
			stub.name = child_name
			add_child(stub)
		var cs := CollisionShape2D.new()
		cs.name = "CollisionShape2D"
		cs.shape = RectangleShape2D.new()
		add_child(cs)


func test_collision_shape_derived_from_cell_size() -> void:
	var host := ShapedHost.new()
	add_child_autofree(host)
	var cs: CollisionShape2D = host.get_node("CollisionShape2D")
	assert_eq(cs.shape.size, Vector2.ONE * (CELL - 2),
		"shape should be CELL_SIZE minus a margin so adjacent entities never touch")
	assert_eq(cs.position, Vector2.ONE * (CELL / 2.0),
		"shape should be centered on the occupied cell")


func test_entity_without_collision_shape_is_fine() -> void:
	# Doubles (and future non-physical entities) may omit the shape entirely.
	var host := ShapedHost.new()
	var cs: CollisionShape2D = host.get_node("CollisionShape2D")
	host.remove_child(cs)
	cs.free()
	add_child_autofree(host)
	pass_test("no error when CollisionShape2D is absent")
