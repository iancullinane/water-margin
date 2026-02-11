extends Node2D

@onready var animation_tree: AnimationTree = $'../AnimationTree'
@onready var sprite: Sprite2D = $'../Sprite'
@onready var entity: IEntity = get_parent()

var last_non_zero_direction: Vector2 = Vector2.DOWN  # Store last direction for persistence


func _physics_process(_delta: float) -> void:
	set_animation(entity.direction)

func set_animation(direction: Vector2):
	# Store last non-zero direction when moving
	if direction.length() > 0:
		last_non_zero_direction = direction

	# Use last direction when not moving
	var anim_direction = direction if direction.length() > 0 else last_non_zero_direction

	# Set the blend position based on direction
	animation_tree.set("parameters/MoveStateMachine/idle/blend_position", anim_direction)

	if anim_direction.x < 0:
		sprite.flip_h = true
	elif anim_direction.x > 0:
		sprite.flip_h = false
