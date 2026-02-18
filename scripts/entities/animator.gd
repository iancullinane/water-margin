extends Node2D

@onready var animation_tree: AnimationTree = $'../AnimationTree'
@onready var sprite: Sprite2D = $'../Sprite'
@onready var entity: IEntity = get_parent()
@onready var mover: Node2D = $'../Mover'
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/MoveStateMachine/playback")

var last_non_zero_direction: Vector2 = Vector2.DOWN
var was_moving: bool = false


func _physics_process(_delta: float) -> void:
	var is_moving = mover.is_moving
	var direction = entity.direction

	if direction.length() > 0:
		last_non_zero_direction = direction

	var anim_direction = direction if direction.length() > 0 else last_non_zero_direction

	# Update blend positions for both states
	animation_tree.set("parameters/MoveStateMachine/idle/blend_position", anim_direction)
	animation_tree.set("parameters/MoveStateMachine/move/blend_position", anim_direction)

	# Transition between idle and move states
	if is_moving and not was_moving:
		state_machine.travel("move")
	elif not is_moving and was_moving:
		state_machine.travel("idle")

	was_moving = is_moving

	if anim_direction.x < 0:
		sprite.flip_h = true
	elif anim_direction.x > 0:
		sprite.flip_h = false
